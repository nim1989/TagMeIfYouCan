# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready( ->
  $("#ajax_loader").hide()
  xhr = $.ajax()
  $("#query_string").keyup((event) ->
    xhr.abort()
    val = $(this).val()
    data = query_string: val
    if data.query_string.length > 3
      $("#ajax_loader").show()
      xhr = $.ajax(
        url     : "search"
        type    : "post"
        data    : data
        dataType: "json"
        success : (results, b, c) ->
          $("#ajax_loader").hide()
          $('#results').empty()
          _.each(results, (result) ->
            $('#results').append('<li>' + result.uri.value + '</li>')
          )         
      )
    )
)