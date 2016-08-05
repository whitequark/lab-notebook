$(".fancybox").fancybox();
$(document).ready(function() {
  $('a[data-show-hide]').each(function(i, el) {
    $("#"+$(el).attr('data-show-hide')).hide();
  });
});
$(document).on('click', 'a[data-show-hide]', function(e) {
  $("#"+$(e.target).attr('data-show-hide')).toggle();
  return false;
});
