#= require arctic_admin/base
#= require activeadmin_addons/all

$(document).ready ->
  $('.image_field').on 'change', ->
    $parent = $(this).parent()
    if @files[0]
      reader = new FileReader
      reader.onload = (e) ->
        if $parent.find('.thumb').length == 0
          $parent.find('.inline-hints').html("<img class='thumb' />")
        $parent.find('.thumb').attr 'src', e.target.result
      reader.readAsDataURL @files[0]
