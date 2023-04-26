library(tidyverse)
library(modeltime)
library(modeltime.gluonts)
library(timetk)
library(tidymodels)

df_today <- readr::read_csv(here::here("ga_dashboard/data/df_today.csv")) %>%
  dplyr::group_by(date) %>%
  dplyr::summarise(page_views = sum(pageviews)) %>%
  dplyr::ungroup()
web_data <- readr::read_csv(here::here("ga_dashboard/data/web_data.csv")) %>%
  dplyr::group_by(date) %>%
  dplyr::summarise(page_views = sum(pageviews)) %>%
  dplyr::ungroup()

prediction_length <- 28
df <- web_data %>%
  dplyr::bind_rows(df_today) %>%
  dplyr::distinct(date, .keep_all = TRUE) %>%
  dplyr::arrange(date) %>%
  timetk::future_frame(.date_var = date, .length_out = 21, .bind_data = TRUE) %>%
  dplyr::mutate(id = as.factor(1))

training <- df[1:(nrow(df)-prediction_length), ]
testing <- df[df$date > max(training$date), ]
recipe <- recipes::recipe(page_views ~ date + id, data = training)

### nbeats ----
nbeats_model <- modeltime.gluonts::nbeats(
  id = "id",
  freq = "D",
  prediction_length = prediction_length,
  lookback_length = prediction_length*c(2, 4, 6, 8, 10, 12),
  bagging_size = 5,
  loss_function = "MASE",
  scale = TRUE,
  epochs = 5,
  num_batches_per_epoch = 16
) %>%
  parsnip::set_engine("gluonts_nbeats_ensemble")

workflow_fit <- workflows::workflow() %>%
  workflows::add_model(nbeats_model) %>%
  workflows::add_recipe(recipe) %>%
  parsnip::fit(training)

models <- modeltime::modeltime_table(
  workflow_fit
)

nbeats_preds <- modeltime::modeltime_forecast(
  models,
  new_data    = testing,
  actual_data = df[!is.na(df$page_views) & df$date >= lubridate::ymd("2022-11-01"), ],
  keep_data = TRUE
)

modeltime::plot_modeltime_forecast(nbeats_preds)

### xgboost ----
rolling_averages <- c(prediction_length)*c(1, 2, 3)
xgboost_df <- df %>%
  timetk::tk_augment_lags(
    .value = page_views,
    .lags  = prediction_length
  ) %>%
  timetk::tk_augment_slidify(
    .value = !!sym(paste0("page_views_lag", prediction_length)),
    .period = rolling_averages,
    .f = ~mean(., na.rm = TRUE),
    .partial = TRUE,
    .align = "center"
  ) %>%
  timetk::tk_augment_fourier(
    .date_var = date,
    .periods = rolling_averages,
    .K = 1
  ) %>%
  dplyr::select(-id)

xg_boost_future <- xgboost_df %>% dplyr::filter(date >= lubridate::ymd("2022-12-02"))
xgboost_df <- xgboost_df %>%
  tidyr::drop_na()

splits <- xgboost_df %>%
  timetk::time_series_split(
    date_var = date,
    assess   = 7,
    cumulative = TRUE
  )

base_recipe <- recipes::recipe(page_views ~ ., data = rsample::training(splits))

remove_variables <- c("date_year.iso", "date_half", "date_month", "date_month.xts", "date_hour", "date_minute",
  "date_second", "date_hour12", "date_am.pm", "date_wday", "date_wday.xts", "date_qday",
  "date_yday", "date_week", "date_week.iso", "date_week2", "date_week3", "date_week4", "date_mday7")

recipe_xg <- base_recipe %>%
  recipes::step_naomit(dplyr::contains("lag"), skip = TRUE) %>%
  timetk::step_timeseries_signature(date) %>%
  recipes::step_rm(date) %>%
  recipes::step_rm(!!!syms(remove_variables)) %>%
  recipes::step_normalize(all_numeric(), -all_outcomes()) %>%
  recipes::step_dummy(recipes::all_nominal(), one_hot = TRUE)
xg_df <- temp %>% prep() %>% juice()
xg_columns <- length(xg_df) - 1

xg_boost_cv_5 <- rsample::vfold_cv(
  rsample::training(splits),
  v = 5
)

model_spec_xg <- parsnip::boost_tree(
  mode = "regression",
  mtry = tune::tune(),
  trees = tune::tune(),
  min_n = tune::tune(),
  tree_depth = tune::tune(),
  learn_rate = tune::tune(),
  loss_reduction = tune::tune()
) %>%
  parsnip::set_engine("xgboost")

workflow_fit_xg <- workflows::workflow() %>%
  workflows::add_model(model_spec_xg) %>%
  workflows::add_recipe(recipe_xg)

grid <- dials::grid_latin_hypercube(
  dials::mtry(range = c(1, xg_columns)),
  dials::trees(),
  dials::min_n(),
  dials::tree_depth() ,
  dials::learn_rate(),
  dials::loss_reduction(),
  size = 20
)

xg_boost_kfold <- workflow_fit_xg %>%
  tune::tune_grid(
    resamples = xg_boost_cv_5,
    grid     = grid,
    metrics  = modeltime::default_forecast_accuracy_metric_set(),
    control  = tune::control_grid(verbose = TRUE, save_pred = TRUE)
  )

plot <- autoplot(xg_boost_kfold)
plotly::ggplotly(plot)

grid <- dials::grid_latin_hypercube(
  dials::mtry(range = c(1, xg_columns)),
  dials::trees(),
  dials::min_n(),
  dials::tree_depth() ,
  dials::learn_rate(range = c(-2.4, -1)),
  dials::loss_reduction(),
  size = 20
)

xg_boost_kfold <- workflow_fit_xg %>%
  tune::tune_grid(
    resamples = xg_boost_cv_5,
    grid     = grid,
    metrics  = modeltime::default_forecast_accuracy_metric_set(),
    control  = tune::control_grid(verbose = TRUE, save_pred = TRUE)
  )

final_xg_model <- workflow_fit_xg %>%
  tune::finalize_workflow(
    xg_boost_kfold %>%
      tune::show_best() %>%
      dplyr::slice(1)
  ) %>%
  parsnip::fit(rsample::training(splits))

models <- modeltime::modeltime_table(
  workflow_fit,
  final_xg_model
)

all_models_preds <- modeltime::modeltime_forecast(
  models,
  new_data    = xg_boost_future %>% dplyr::mutate(id = as.factor(1)),
  actual_data = xgboost_df %>% dplyr::mutate(id = as.factor(1)) %>% dplyr::filter(date >= lubridate::ymd("2022-11-01")),
  keep_data = TRUE
)

modeltime::plot_modeltime_forecast(all_models_preds)

readr::write_csv(all_models_preds, here::here("ga_dashboard/data/time_series.csv"))
