class MagicOrders.Views.TradesAdvancedSearch extends Backbone.View

  template: JST['trades/advanced_search']

  events:
    'click .add_time_search_tag': 'addTimeSearchTag'
    'click .add_money_search_tag': 'addMoneySearchTag'
    'click .add_status_search_tag': 'addStatusSearchTag'
    'click .add_memo_search_tag' : 'addMemoSearchTag'
    'click .add_type_search_tag': 'addTypeSearchTag'
    'click .add_source_search_tag': 'addSourceSearchTag'
    'click .add_area_search_tag': 'addAreaSearchTag'
    'click .add_merge_type_search_tag': 'addMergeTypeSearchTag'
    'click .add_batch_search_tag': 'addBatchSearchTag'
    'click .advanced_btn': 'advancedSearch'
    'click .add_printable': 'addPrintable'
    'click .add_logistics_printable': 'addLogisticsPrintable'
    'click .remove_search_tag': 'removeSearchTag'
    'change .search_option' : 'changeInputFrame'
    'change #simple_load_search_criteria': 'simpleLoadSearchCriteria'
    'change #load_search_criteria': 'loadSearchCriteria'
    'click #save_search_criteria': 'saveSearchCriteria'

  initialize: ->
    @updateSearchCriteriaSelection()

  render: ->
    $(@el).html(@template())
    self = this

    $.validator.addMethod "search_criteria_uniq", ((value) ->
      for search_criteria in self.criteria_collection.models
        if search_criteria.get("name") ==  value
           return false
      return true
      ), "名称已经存在"


    $("#save_search_criteria_form").submit (e)->
      criteria = new MagicOrders.Models.TradeSearch
      form = $(this)
      if !form.valid()
        return false
      $("#save_search_criteria_modal").modal("hide")
      name = $("input[name=name]",form).val()
      if name == null || name.trim() == ''
        return

      search_hash = {}
      inputItems = $('.search_tags_group').children().find('input')
      for idx in [0..(inputItems.length - 1)]
        jqueryItem = $(inputItems[idx])
        attr_name = jqueryItem.attr("name")
        search_hash[attr_name] ||= []
        search_hash[attr_name].push(jqueryItem.val())
      criteria.save {
       html:$(".search_tags_group").html(),
       search_hash: search_hash,
       trade_mode: MagicOrders.trade_mode,
       trade_type: MagicOrders.trade_type,
       name:name
      }, success: (model,response) ->
        #@search_criterias.push(model)
        self.updateSearchCriteriaSelection()
      return false

    $("#save_search_criteria_form").validate
      rules:
        name:
          required:true
          maxlength:7
          search_criteria_uniq: true
      messages:
        name:
          required:"请输入名称"
          maxlength:"名称不能超过7个字符"

      highlight: (element)  ->
        $(element).closest('.control-group').removeClass('success').addClass('error')
      success: (element) ->
       element
       .text('OK!').addClass('valid')
       .closest('.control-group').removeClass('error').addClass('success')
      errorPlacement: (error, element) ->
        element.closest('.control-group').find('span.help-inline').html(error.text())

    $(@el).find('.order_search_form .datepickers').datetimepicker(weekStart:1,todayBtn:1,autoclose:1,todayHighlight:1,startView:2,forceParse:0,showMeridian:1)
    @render_select_state()
    $(@el).find(".select2").select2();
    $(@el).find(".search_logistic").hide()  #一定要放在select2()初始化之后！
    $(@el).find('.add_status_search_tag').parents('fieldset').hide()
    if MagicOrders.trade_mode == 'trades'
      $(@el).find('.add_batch_search_tag').parents('fieldset').hide()
    if MagicOrders.trade_mode == "trades" && (MagicOrders.trade_type == "all" || MagicOrders.trade_type == "my_trade")
      $(@el).find('.add_status_search_tag').parents('fieldset').show()
    this

  # 加载地域搜索框
  render_select_state: ->
    view = new MagicOrders.Views.AreasSelectState()
    $(@el).find('#select_state').html(view.render().el)

  changeInputFrame: ->
    if $(".search_option").children('option:selected').val() == "logistic_name"
      $(".search_logistic").show()
      $(".search_value").hide()
    else
      $(".search_logistic").hide()
      $(".search_value").show()

  advancedSearch: (e) ->
    e.preventDefault()
    $("#search_toggle").toggle()
    $('.advanced_in_the_air').toggleClass 'simple_search'
    $("#simple_search_button").toggleClass 'simple_search'
    $("#simple_load_search_criteria").toggle()
    $("#content").toggleClass("search-expand")

  getText: (element,child_one,sibling='div',child_two='option:selected') ->
    $(element).siblings(sibling).children(child_one).children(child_two).text()

  getSearchValue: (element,child,sibling='div') ->
    $(element).siblings(sibling).children(child).val()

  check_tag_exist:(tag,value)->
    if tag.length > 0 && tag.map ->
      $(this).val()
    .toArray().indexOf(value)>=0
      return true
    return false


  addTimeSearchTag: (e) ->
    e.preventDefault()
    time_type = @getSearchValue('.add_time_search_tag','select')
    time_type_text = @getText('.add_time_search_tag','select')
    start_at = @getSearchValue('.add_time_search_tag','input:first')
    end_at = @getSearchValue('.add_time_search_tag','input:last')

    tag = $(".search_tags_group input[name="+time_type+"]")
    if start_at != '' and end_at != ''
      value = start_at+";"+end_at
      if @check_tag_exist tag,value
        alert("该搜索条件已经添加过")
        return false
      $('.search_tags_group').append("<span class='search_tag pull-left time_search'>"+
                                     "<label class='help-inline'>"+time_type_text+" "+start_at+" 至 "+end_at+"</label>"+
                                     "<input type='hidden' name='"+time_type+"' value='"+value+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")
    else
      alert("请输入完整的起始时间。")

  addStatusSearchTag: (e) ->
    e.preventDefault()
    status_boolean = @getSearchValue('.add_status_search_tag','select:first')
    status = @getSearchValue('.add_status_search_tag','select:last')
    status_boolean_text = @getText('.add_status_search_tag','select:first')
    status_text = @getText('.add_status_search_tag','select:last')

    if status.slice(0,6) == 'status'
      tag = $(".search_tags_group input[name=status]")
    else
      tag = $(".search_tags_group input[name="+status+"]")

    if status.slice(0,6) == 'status'
      value = status+";"+status_boolean
      if @check_tag_exist tag,value
        alert("该搜索条件已经添加过")
        return false
      $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+status_boolean_text+" "+status_text+"</label>"+
                                     "<input type='hidden' name='status' value='"+value+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")
    else
      value = status_boolean
      if @check_tag_exist tag,value
        alert("该搜索条件已经添加过")
        return false
      $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+status_boolean_text+" "+status_text+"</label>"+
                                     "<input type='hidden' name='"+status+"' value='"+value+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")


  addMemoSearchTag: (e) ->
    e.preventDefault()
    memo_boolean = @getSearchValue('.add_memo_search_tag','select:eq(0)')
    has_memo = @getSearchValue('.add_memo_search_tag','select:eq(1)')
    memo_boolean_text = @getText('.add_memo_search_tag','select:eq(0)')
    memo_type_text = @getText('.add_memo_search_tag','select:eq(1)')

    memo_type = has_memo.slice(4)
    include_boolean = @getSearchValue('.add_memo_search_tag','select:eq(2)')
    include_text = @getSearchValue('.add_memo_search_tag','input')
    include_boolean_text = @getText('.add_memo_search_tag','select:eq(2)')

    tag = $(".search_tags_group input[name="+has_memo+"]")
    value = memo_type+";"+memo_boolean+";"+include_text+";"+include_boolean
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false
    $('.search_tags_group').append("<span class='search_tag pull-left memo_search'>"+
                                   "<label class='help-inline'>"+memo_boolean_text+" "+memo_type_text+
                                   " "+include_boolean_text+" "+include_text+"</label>"+
                                   "<input type='hidden' name="+has_memo+" value='"+value+"'>"+
                                   "<button class='remove_search_tag' value=''> x </button></span>")

  addTypeSearchTag: (e) ->
    e.preventDefault()
    type = @getSearchValue('.add_type_search_tag','select')
    type_text = @getText('.add_type_search_tag','select')

    tag = $(".search_tags_group input[name=_type]")
    value = type
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false

    $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+type_text+"</label>"+
                                     "<input type='hidden' name='_type' value='"+type+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")

  addSourceSearchTag: (e) ->
    e.preventDefault()
    source_id = @getSearchValue('.add_source_search_tag','select')
    source_text = @getText('.add_source_search_tag','select')

    tag = $(".search_tags_group input[name=source]")
    value = source_id
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false

    $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+source_text+"</label>"+
                                     "<input type='hidden' name='source' value='"+source_id+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")


  addMergeTypeSearchTag:(e)->
    e.preventDefault()
    type = @getSearchValue('.add_merge_type_search_tag','select')
    type_text = @getText('.add_merge_type_search_tag','select')

    tag = $(".search_tags_group input[name=merge_type]")
    value = type
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false
    $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+type_text+"</label>"+
                                     "<input type='hidden' name='merge_type' value='"+type+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")

  addPrintable:(e)->
    e.preventDefault()
    type = @getSearchValue('.add_printable','select')
    type_text = @getText('.add_printable','select')

    tag = $(".search_tags_group input[name=print_at]")
    value = type
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false
    $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+type_text+"</label>"+
                                     "<input type='hidden' name='print_at' value='"+type+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")

  addLogisticsPrintable:(e)->
    e.preventDefault()
    type = @getSearchValue('.add_logistics_printable','select')
    type_text = @getText('.add_logistics_printable','select')

    tag = $(".search_tags_group input[name=logistics_print_at]")
    value = type
    if @check_tag_exist tag,value
      alert("该搜索条件已经添加过")
      return false
    $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                     "<label class='help-inline'>"+type_text+"</label>"+
                                     "<input type='hidden' name='logistics_print_at' value='"+type+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")

  addAreaSearchTag: (e) ->
    e.preventDefault()
    state = $('#state_option').val()
    city = $('#city_option').val()
    district = $('#district_option').val()

    tag = $(".search_tags_group input[name=area]")
    if state != '' || city != '' || district != ''
      value = district+";"+city+";"+state
      if @check_tag_exist tag,value
        alert("该搜索条件已经添加过")
        return false
      $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                       "<label class='help-inline'>"+state+" "+city+" "+district+"</label>"+
                                       "<input type='hidden' name='area' value='"+value+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")

    else
      alert("请至少选择一级地区。")

  addMoneySearchTag: (e) ->
    e.preventDefault()
    money_type = @getSearchValue('.add_money_search_tag','select')
    money_type_text = @getText('.add_money_search_tag','select')
    min_money = @getSearchValue('.add_money_search_tag','input:first')
    max_money = @getSearchValue('.add_money_search_tag','input:last')

    tag = $(".search_tags_group input[name="+money_type+"]")
    if min_money != '' and max_money != ''
      if /^[0-9.]*$/.test(min_money) and /^[0-9.]*$/.test(min_money)
        value = min_money+";"+max_money
        if @check_tag_exist tag,value
          alert("该搜索条件已经添加过")
          return false
        $('.search_tags_group').append("<span class='search_tag pull-left money_search'>"+
                                       "<label class='help-inline'>"+money_type_text+" "+min_money+" 至 "+max_money+"</label>"+
                                       "<input type='hidden' name='"+money_type+"' value='"+value+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
      else
        alert("金额格式不正确。")

    else
      alert("请输入完整的区间。")

  addBatchSearchTag: (e) ->
    e.preventDefault()
    from = $('#from_batch_num').val()
    to = $('#to_batch_num').val()
    tag = $(".search_tags_group input[name=batch]")
    if tag == undefined || tag.length == 0
      if from != '' && to != ''
        value = from+";"+to
        if @check_tag_exist tag,value
          alert("该搜索条件已经添加过")
          return false
        $('.search_tags_group').append("<span class='search_tag pull-left' id='batch_search_tag'>"+
                                       "<label class='help-inline'>批次号："+from+" 至 "+to+"</label>"+
                                       "<input type='hidden' name='batch' value='"+value+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
      else
        alert("单号填写不完整。")
    else
      alert("已经添加过批次")

  removeSearchTag: (e) ->
    e.preventDefault()
    $(e.currentTarget).parent('.search_tag').remove()

  saveSearchCriteria:(e)->
    self = this
    e.preventDefault()
    $("#save_search_criteria_modal").modal("show")

  simpleLoadSearchCriteria:(e)->
    e.preventDefault()
    $("#load_search_criteria").val($(e.target).val()).change()
    if(!$("#search_toggle").is(":visible"))
      $(".advanced_btn:first").click()
    $(".search").click()

  simpleLoadSearchCriteria:(e)->
    e.preventDefault()
    $("#load_search_criteria").val($(e.target).val()).change()
    if(!$("#search_toggle").is(":visible"))
      $(".advanced_btn:first").click()
    $(".search").click()

  loadSearchCriteria:(e)->
    e.preventDefault()
    criteria_id = e.target.value
    criteria = $.grep @search_criterias,(obj)->
      if(obj.get("_id")==criteria_id)
        return true
    criteria = criteria[0]
    if criteria
      $('.search_tags_group').html(criteria.get("html"))

  updateSearchCriteriaSelection: ->
    self = this
    @criteria_collection = new MagicOrders.Collections.TradeSearches
    @criteria_collection.fetch success: (collection)->
      self.search_criterias = collection.models
      $("#load_search_criteria").html('').append("<option value=''>加载搜索条件</option>")
      $("#simple_load_search_criteria").html('').append("<option value=''>加载搜索条件</option>")
      $("#global-menus a[data-search-criteria]").parent("li").remove()
      $("#global-menus li.seprator").remove()
      $("#global-menus").append("<li class='seprator'><span style='margin: 3px 15px;display: block;'>|</span></li>")
      $("#global-menus").append("<li class='dropdown'><a href='#'' class='dropdown-toggle' id='select_trade' data-toggle='dropdown'>选择自定义页面 <b class='caret'></b></a><ul class='dropdown-menu' id='select-dropdown-menu'></ul></li>")
      $(self.search_criterias).each (index,criteria)->
        $("#load_search_criteria").append("<option value='"+criteria.get("_id")+"'>"+criteria.get("name")+"</option>")
        if criteria.get("show_in_simple_model") == true
          $("#simple_load_search_criteria").append("<option value='"+criteria.get("_id")+"'>"+criteria.get("name")+"</option>")
        if criteria.get("show_in_tabs")
          trade_mode = criteria.get("trade_mode") || "trades"
          trade_type = criteria.get("trade_type") || "all"
          $("#select-dropdown-menu").append("<li><a href='#' data-trade-mode='"+trade_mode+"' data-trade-status='"+trade_type+"' data-search-id='"+criteria.get("_id")+"'>"+criteria.get("name")+"<em></em></a></li>")

          switch trade_mode
            when "trades"
              coll = new MagicOrders.Collections.Trades()
            when "deliver_bills"
              coll = new MagicOrders.Collections.DeliverBills()
            when "logistic_bills"
              coll = new MagicOrders.Collections.DeliverBills()
          coll.fetch  data:{trade_type:trade_type, trade_status:trade_type, search_id:criteria.get("_id"),limit:1}, success: (collection, response)->
            count = 0
            if(collection.length > 0)
              count = collection.models[0].get("trades_count") || collection.models[0].get("bills_count")
            $("[data-search-id='"+criteria.get("_id")+"'] em").text("("+count+")")
            if $(".dropdown-menu li.active a").length > 0
              $("#select_trade").text($(".dropdown-menu li.active a").text())
              $("#select_trade").append("<b class='caret'></b>")
      if MagicOrders.search_id
        currentLink = $("#global-menus").find('a[data-search-id="'+MagicOrders.search_id+'"]').first()
      else
        currentLink = $("#global-menus").find('a[data-trade-mode='+MagicOrders.trade_mode+'][data-trade-status="'+MagicOrders.trade_type+'"]').first()

      if currentLink
        currentLink.parents("li").addClass("active")
        $("#current_name").text(currentLink.text())
    if $(window).width() > 979
      $(".js-fixed_header").fixedHeader({
        topOffset: 68
      })

