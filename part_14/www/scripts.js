// remove plot and add action link
$(document).on("click", ".delete", function() {

  var clicked_id = $(this).attr('id');
  var header_h2 = $("#" + clicked_id).parent().parent().text().trim();
  $(".class_" + clicked_id).remove();
console.log("hello");
  var html = '<div class="added_' + clicked_id +
  '"><a id="' + clicked_id + '" href="#" class="action-button added_btn">' + header_h2 + '</a>'

  if ($( "[class^='added_']" ).length) {
        last_class_added = document.querySelectorAll("[class^='added_']");
        added_class = last_class_added[last_class_added.length - 1].className;
        $(html).insertAfter($("." + added_class));
    } else {
        $(html).insertAfter($('#sidebar-header-sidebar'));
    }

})

// add plot and remove action link
$(document).on("click", ".added_btn", function() {

  var clicked_id = $(this).attr('id');
  var p = $("#" + clicked_id).parent().text();
  var p = $.trim(p);
  Shiny.setInputValue('header', p, {priority: 'event'});
  $(".added_" + clicked_id).remove();

  if($("[class^='class_']").length) {
      last_panel = $("[class^='class_']").last().attr("class");
      Shiny.setInputValue('last_panel', last_panel, {priority: 'event'});
  } else {
      Shiny.setInputValue('last_panel', '#placeholder', {priority: 'event'});
  }

  Shiny.setInputValue('add_btn_clicked', clicked_id, {priority: 'event'});

})

function open_sidebar() {
    document.getElementById('menu').style.width = "250px";
    document.getElementById('entire-sidebar').style.marginLeft = "250px";
}

function close_sidebar() {
    document.getElementById('menu').style.width = "0px";
    document.getElementById('entire-sidebar').style.marginLeft = "0px";
}

$('#open').click(function () {
   $('#open').css('opacity', '0.0');
});

$('#close').click(function () {
   $('#open').css('opacity', '1.0');
});


document.getElementById("get-data-go").addEventListener(
    "click",
    function() {
      current_vizs = Array.from(document.getElementsByClassName("panel-title"));
      const current_viz_header = [];

      current_vizs.forEach(function(element) {
        current_viz_header.push(element.innerHTML)
      });

      /*  send array with current visualizations on the main page */
      Shiny.setInputValue('viz_on_page', current_viz_header, {priority: 'event'});

});

shinyjs.remove_plots_date_change = function() {

  plolty_plots = document.querySelectorAll("[id^='htmlwidget-']")
  const plolty_plots_ids = [];

  /*  create array of ids */
  plolty_plots.forEach(function(element) {
    plolty_plots_ids.push(element.id)
  });

  /*  remove plotly-plots and not html */
  plolty_plots_ids.forEach(function(element) {
    $("#" + element).remove();
  });

};
