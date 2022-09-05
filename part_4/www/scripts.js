// remove plot and add action link
$(document).on("click", ".delete", function() {

  var clicked_id = $(this).attr('id');
  var header_h2 = $("#" + clicked_id).parent().parent().text().trim();
  $(".class_" + clicked_id).remove();

  var html = '<div class="added_' + clicked_id +
  '"><a id="' + clicked_id + '" href="#" class="action-button added_btn">' + header_h2 + '</a>'

  if ($( "[class^='added_']" ).length) {
        last_class_added = document.querySelectorAll("[class^='added_']");
        added_class = last_class_added[last_class_added.length - 1].className;
        $(html).insertAfter($("." + added_class));
    } else {
        last_class_added = document.querySelectorAll("[class^='class_']");
        added_class = last_class_added[last_class_added.length - 1].className;
        $(html).insertAfter($("." + added_class));
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
