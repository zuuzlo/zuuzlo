# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $container = $('#coupons')
  $container.imagesLoaded ->
    $container.masonry
      itemSelector: '.box'
      isFitWidth: true
    return
  $container.infinitescroll {
    navSelector: '#page-nav'
    nextSelector: 'a.next_page'
    itemSelector: '.box'
    loading:
      finishedMsg: 'No more pages to load.'
      img: 'http://i.imgur.com/6RMhx.gif'
  }, (newElements) ->
    # hide new items while they are loading
    $newElems = $(newElements).css(opacity: 0)
    # ensure that images load before adding to masonry layout
    $newElems.imagesLoaded ->
      # show elems now they're ready
      $newElems.animate opacity: 1
      $container.masonry 'appended', $newElems, true
      return
    return
  return