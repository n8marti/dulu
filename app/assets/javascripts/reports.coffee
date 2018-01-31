add_cluster_program = (type, id, name) ->
  add_me = "<span>"
  input_name = type + "_ids[]" # eg cluster => cluster_ids[]
  add_me += "<input type='hidden' name='#{input_name}' value='#{id}'>"
  add_me += name + ' '
  add_me += "<a href='#' class='btn btn-xs btn-danger'>X</a>"
  add_me += "</span> "
  $('#report-languages-none').hide()
  $('#report-languages').append(add_me)

remove_cluster_program = (element) ->
  $(element).closest('span').fadeOut 'fast', ->
    $(this).remove()

$(document).ready ->
  switch $('body').data('page-name')
    when 'reports#index'
      $('a[data-add-cluster]').click (e) ->
        e.preventDefault()
        select = $('#add_cluster')
        id = select.val()
        name = select.find('option:selected').text()
        add_cluster_program('cluster', id, name)

      $('#report-languages').click (e) ->
        if(e.target.nodeName.toLowerCase() == 'a')
          e.preventDefault()
          remove_cluster_program(e.target)

