class MagicOrders.Views.TradesAdvancedSearch extends Backbone.View

  template: JST['trades/advanced_search']

  events:
    'click .add_time_search_tag': 'addTimeSearchTag'
    'click .add_money_search_tag': 'addMoneySearchTag'
    'click .add_status_search_tag': 'addStatusSearchTag'
    'click .add_memo_search_tag' : 'addMemoSearchTag'
    'click .add_source_search_tag': 'addSourceSearchTag'
    'click .add_area_search_tag': 'addAreaSearchTag'
    'click .add_batch_search_tag': 'addBatchSearchTag'
    'click .advanced_btn': 'advancedSearch'
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
      criteria.save {
       html:$(".search_tags_group").html(),
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
    if MagicOrders.trade_mode == "trades" && MagicOrders.trade_type == "all"
      $(@el).find('.add_status_search_tag').parents('fieldset').show()
    this

  # 用于对齐高级搜索栏和操作菜单栏
  catchSearchMotion: ->
    out_height = $('.js-affix').outerHeight();
    $('.btn-toolbar').css('top', out_height + 71 + 'px');

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
    @catchSearchMotion()
    $('.advanced_in_the_air').toggleClass 'simple_search'
    $("#simple_search_button").toggleClass 'simple_search'
    $("#simple_load_search_criteria").toggle()
    $("#content").toggleClass("search-expand")

  getText: (element,child_one,sibling='div',child_two='option:selected') ->
    $(element).siblings(sibling).children(child_one).children(child_two).text()

  getSearchValue: (element,child,sibling='div') ->
    $(element).siblings(sibling).children(child).val()

  addTimeSearchTag: (e) ->
    e.preventDefault()
    time_type = @getSearchValue('.add_time_search_tag','select')
    time_type_text = @getText('.add_time_search_tag','select')
    start_at = @getSearchValue('.add_time_search_tag','input:first')
    end_at = @getSearchValue('.add_time_search_tag','input:last')

    tag = $(".search_tags_group input[name="+time_type+"]").attr('name')
    if tag == undefined
      if start_at != '' and end_at != ''
        $('.search_tags_group').append("<span class='search_tag pull-left time_search'>"+
                                       "<label class='help-inline'>"+time_type_text+" "+start_at+" 至 "+end_at+"</label>"+
                                       "<input type='hidden' name='"+time_type+"' value='"+start_at+";"+end_at+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
        @catchSearchMotion()
      else
        alert("请输入完整的起始时间。")
    else
      alert("已经添加过 "+time_type_text+" 搜索条件，一个时间条件只能添加一次")

  addStatusSearchTag: (e) ->
    e.preventDefault()
    status_boolean = @getSearchValue('.add_status_search_tag','select:first')
    status = @getSearchValue('.add_status_search_tag','select:last')
    status_boolean_text = @getText('.add_status_search_tag','select:first')
    status_text = @getText('.add_status_search_tag','select:last')

    if status.slice(0,6) == 'status'
      tag = $(".search_tags_group input[name=status]").attr('name')
    else
      tag = $(".search_tags_group input[name="+status+"]").attr('name')

    if tag == undefined
      if status.slice(0,6) == 'status'
        $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                       "<label class='help-inline'>"+status_boolean_text+" "+status_text+"</label>"+
                                       "<input type='hidden' name='status' value='"+status+";"+status_boolean+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
      else
        $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                       "<label class='help-inline'>"+status_boolean_text+" "+status_text+"</label>"+
                                       "<input type='hidden' name='"+status+"' value='"+status_boolean+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
      @catchSearchMotion()
    else
      if status.slice(0,6) == 'status'
        tag_name = $(".search_tags_group input[name=status]").siblings('label').text()
        alert("已经添加过 "+tag_name+", 当前状态只能添加一次")
      else
        tag_name = $(".search_tags_group input[name="+status+"]").siblings('label').text()
        alert("已经添加过 "+tag_name)


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

    tag = $(".search_tags_group input[name="+has_memo+"]").attr('name')
    if tag == undefined
      $('.search_tags_group').append("<span class='search_tag pull-left memo_search'>"+
                                     "<label class='help-inline'>"+memo_boolean_text+" "+memo_type_text+
                                     " "+include_boolean_text+" "+include_text+"</label>"+
                                     "<input type='hidden' name="+has_memo+" value='"+memo_type+";"+memo_boolean+";"+include_text+";"+include_boolean+"'>"+
                                     "<button class='remove_search_tag' value=''> x </button></span>")
      @catchSearchMotion()
    else
      alert("已经添加过 "+memo_type_text+" 搜索条件，一个备注条件只能添加一次")

  addSourceSearchTag: (e) ->
    e.preventDefault()
    type = @getSearchValue('.add_source_search_tag','select')
    type_text = @getText('.add_source_search_tag','select')

    tag = $(".search_tags_group input[name=_type]").attr('name')
    if tag == undefined
      $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                       "<label class='help-inline'>"+type_text+"</label>"+
                                       "<input type='hidden' name='_type' value='"+type+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
      @catchSearchMotion()
    else
      tag_name = $(".search_tags_group input[name=_type]").siblings('label').text()
      alert("已经添加过 "+tag_name+" 来源, 来源只能添加一种")

  addAreaSearchTag: (e) ->
    e.preventDefault()
    state = $('#state_option').val()
    city = $('#city_option').val()
    district = $('#district_option').val()

    tag = $(".search_tags_group input[name=area]").attr('name')
    if tag == undefined
      if state != '' || city != '' || district != ''
        $('.search_tags_group').append("<span class='search_tag pull-left'>"+
                                         "<label class='help-inline'>"+state+" "+city+" "+district+"</label>"+
                                         "<input type='hidden' name='area' value='"+district+";"+city+";"+state+"'>"+
                                         "<button class='remove_search_tag' value=''> x </button></span>")
        @catchSearchMotion()
      else
        alert("请至少选择一级地区。")
    else
      tag_name = $(".search_tags_group input[name=area]").siblings('label').text()
      alert("已经添加过 "+tag_name+" 地区, 地区只能添加一个")

  addMoneySearchTag: (e) ->
    e.preventDefault()
    money_type = @getSearchValue('.add_money_search_tag','select')
    money_type_text = @getText('.add_money_search_tag','select')
    min_money = @getSearchValue('.add_money_search_tag','input:first')
    max_money = @getSearchValue('.add_money_search_tag','input:last')

    tag = $(".search_tags_group input[name="+money_type+"]").attr('name')
    if tag == undefined
      if min_money != '' and max_money != ''
        if /^[0-9.]*$/.test(min_money) and /^[0-9.]*$/.test(min_money)
          $('.search_tags_group').append("<span class='search_tag pull-left money_search'>"+
                                         "<label class='help-inline'>"+money_type_text+" "+min_money+" 至 "+max_money+"</label>"+
                                         "<input type='hidden' name='"+money_type+"' value='"+min_money+";"+max_money+"'>"+
                                         "<button class='remove_search_tag' value=''> x </button></span>")
        else
          alert("金额格式不正确。")
        @catchSearchMotion()
      else
        alert("请输入完整的区间。")
    else
      alert("已经添加过 "+money_type_text+" 搜索条件，一个金额条件只能添加一次")

  addBatchSearchTag: (e) ->
    e.preventDefault()
    from = $('#from_batch_num').val()
    to = $('#to_batch_num').val()
    tag = $(".search_tags_group input[name=batch]").attr('name')
    if tag == undefined
      if from != '' && to != ''
        $('.search_tags_group').append("<span class='search_tag pull-left' id='batch_search_tag'>"+
                                       "<label class='help-inline'>批次号："+from+" 至 "+to+"</label>"+
                                       "<input type='hidden' name='batch' value='"+from+";"+to+"'>"+
                                       "<button class='remove_search_tag' value=''> x </button></span>")
        @catchSearchMotion()
      else
        alert("单号填写不完整。")
    else
      alert("已经添加过批次")

  removeSearchTag: (e) ->
    e.preventDefault()
    $(e.currentTarget).parent('.search_tag').remove()
    @catchSearchMotion()

  saveSearchCriteria:(e)->
    self = this
    e.preventDefault()
    $("#save_search_criteria_modal").modal("show")

  submitSearchCriteriaForm:(e)->



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
      $(self.search_criterias).each (index,criteria)->
        $("#load_search_criteria").append("<option value='"+criteria.get("_id")+"'>"+criteria.get("name")+"</option>")
        if criteria.get("show_in_simple_model") == true
          $("#simple_load_search_criteria").append("<option value='"+criteria.get("_id")+"'>"+criteria.get("name")+"</option>")
        if criteria.get("show_in_tabs")
          $("#global-menus").append("<li><a href='#' data-search-criteria='"+criteria.get("_id")+"'>"+criteria.get("name")+"</a></li>")







