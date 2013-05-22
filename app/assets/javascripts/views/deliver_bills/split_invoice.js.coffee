class MagicOrders.Views.DeliverBillsSplitInvoice extends Backbone.View

  template: JST['deliver_bills/split_invoice']

  events:
    'click button.js-save': 'save'
    'click button.js-dualboxs_add': "new_select"
    'hover feildset': "hover"
    'click .js-remove': 'remove'
    'click .icon-chevron-right': 'move_right'
    'click .icon-chevron-left': 'move_left'
    'submit #split_invoice_form': "handleSubmit"

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(bill: @model))
    $('#myTab a:first').tab('show');
    $('div.modal-header h3 span').parents('.modal').removeClass('bigtoggle_parents');
    this

  save: (e)->
    blocktheui()
    button = $(e.currentTarget)
    if button.data('source') is 'pre-process'
      @pre_process()

  hover: (e) ->
    $(e.currentTarget).children('div').toggleClass('hidden')

  remove: (e) ->
    $(e.currentTarget).parents('feildset').find('.js-selects').children().appendTo('#splits_select1');
    $(e.currentTarget).parents('feildset').remove()

  move_right: (e) ->
    $parents = $(e.currentTarget).parents('feildset')
    selected = $parents.prevAll().find('option:selected').remove()
    $parents.find('select').append(selected).find('option').prop('selected',true)

  move_left: (e) ->
    $parents = $(e.currentTarget).parents('feildset')
    selected = $parents.nextAll().add($parents).find('option:selected').remove()
    $parents.prev().find('select').append(selected).find('option').prop('selected',true)

  new_select: (e) ->
    id_num = $(e.currentTarget).parents('.dualboxs').find('.js-manually_split').find('select').length + 1
    hf = '<feildset class="pull-left splits_select"><label class="pull-left dualcontrol nomargin"><i class="icon-chevron-right"></i><br><i class="icon-chevron-left"></i></label><select multiple="multiple" id="splits_select'
    hl = '" name="split_invoice_id[1'+ id_num + '][]"' + 'class="js-selects"></select><div class="control-group hidden"><button class="btn btn-mini js-remove" type="button">删除</button></div></feildset>'
    $(e.currentTarget).parents('.dualboxs').find('.js-manually_split').append(hf + id_num + hl)

  handleSubmit: (e) ->
    $form = $(e.currentTarget)
    authenticity_token = $("meta[name=\'csrf-token\']").attr('content')
    $form.children("input[name='authenticity_token']").val(authenticity_token)
    $valid = true
    e.preventDefault()
    if $form.find("select").length < 2
      alert("请拆分后在提交")
    $form.find("select").each (i) ->
      if $(this).find("option").length < 1
        $valid = false
      $(this).find("option").prop("selected",true)
    if $valid
      $form.ajaxSubmit(success: @handleResponse, error: @handleError)
    else
      alert("不能为空值,请先关闭或赋值后在提交")

  handleResponse: (response, status, xhr, form) =>
    $("a[rel=popover]").popover({placement: 'left', html:true})
    $('#split_invoice').modal('hide')
    Backbone.history.navigate('#deliver_bills/deliver_bills-all', true)


  handleError: (response, status, xhr, form) =>
    alert response.responseText