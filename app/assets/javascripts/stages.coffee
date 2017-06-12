# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("button[data-edit-stage-id]").click (e) ->
    e.preventDefault()
    stage_id = $(this).data("edit-stage-id")
    $('#stage-row-view-' + stage_id).fadeOut('fast', ->
      $('#stage-row-form-'+ stage_id).fadeIn('fast'))

$(document).ready ->
  $("button[data-cancel-edit-stage-id]").click (e) ->
    e.preventDefault()
    stage_id = $(this).data("cancel-edit-stage-id")
    $('#stage-row-form-' + stage_id).fadeOut('fast', ->
      $('#stage-row-view-' + stage_id).fadeIn('fast'))

$(document).ready ->
  $('#show-update-form').click (e) ->
    e.preventDefault()
    $(this).fadeOut('fast', ->
      $('#update-stage-form').fadeIn('fast'))