$(document).on("click", ".delete", function() {

  clicked_id = $(this).attr('id');
  header_h2 = $("#" + clicked_id).parent().parent().text().trim();
  $(".class_" + clicked_id).remove();

  Shiny.setInputValue('deleted_plot', clicked_id, {priority: 'event'});

  html = '<div class="added_' + clicked_id +
  '"><a id="' + clicked_id + '" href="#" class="action-button added_btn">' + header_h2 + '</a>'

  if ($( "[class^='added_']" ).length) {
        last_class_added = document.querySelectorAll("[class^='added_']");
        added_class = last_class_added[last_class_added.length - 1].className;
        $(html).insertAfter($("." + added_class));
    } else {
        $(html).insertAfter($("#sidebar-header-sidebar"));
    }

})


$(document).on('click', ".added_btn", function() {

  clicked_id = $(this).attr('id');
  p = $('#' + clicked_id).parent().text().trim();
  Shiny.setInputValue("header", p, {priority: 'event'});
  $(".added_" + clicked_id).remove();

  if( $( "[class^='class_']" ).length ) {
    last_panel = $( "[class^='class_']" ).last().attr('class');
    console.log(last_panel);
    Shiny.setInputValue('last_panel', last_panel, {priority: 'event'});
  } else {
    Shiny.setInputValue('last_panel', "#placeholder");
  }

  Shiny.setInputValue('clicked_link', clicked_id, {priority: 'event'});

})

function open_sidebar() {
  document.getElementById("menu").style.width = "250px";
}

function close_sidebar() {
  document.getElementById("menu").style.width = "0px";
}

$("#open").click(function() {
  $("#open").css("opacity", 0.0)
})

$("#close").click(function() {
  $("#open").css("opacity", 1)
})

$("#close").click(function() {
  $("#close").css("opacity", 0.0)
})

$("#open").click(function() {
  $("#close").css("opacity", 1)
})

document.getElementById("get_data-api_call").addEventListener(
  "click",
  function() {

    current_viz = Array.from(document.getElementsByClassName("panel-title"));
    current_viz_on_page = [];

    current_viz.forEach(function(element) {
      current_viz_on_page.push(element.innerHTML);
    })

    Shiny.setInputValue("current_viz", current_viz_on_page, {priority: 'event'});

  }
)

shinyjs.remove_plotly_plots = function() {

  all_plotly_plots = document.querySelectorAll("[id^='htmlwidget-']");
  all_ids = [];

  all_plotly_plots.forEach(function(element) {
      all_ids.push(element.id);
  });

  all_ids.forEach(function(element) {
      $("#" + element).remove();
  });

}



