var ready;
ready = function(){
  $( ".thumbnail.coupon" ).equalizeHeights()
  $( ".well.store" ).equalizeHeights()
  $(".store_img").popover()
  $(".link_button").popover()
  $(".fav_toggle").tooltip()
  $(".email_tool_tip").tooltip()
};

$(document).ready(ready);
$(document).on("page:load", ready);
$(document).on("page:change", ready);

$.fn.equalizeHeights = function() {
  var maxHeight = this.map(function( i, e ) {
    return $( e ).height();
  }).get();
  return this.height( Math.max.apply( this, maxHeight ) );
};