$(document).ready(function() {
  $(".vocab-item").click(function() {
    $(this).toggleClass("hide");
  });

  $("#toggle-hide").click(function() {
    $("#vocab-container").toggleClass("show-hidden");
  });

  $("#toggle-pinyin").click(function() {
    $("#vocab-container").toggleClass("hide-pinyin");
  });
});
