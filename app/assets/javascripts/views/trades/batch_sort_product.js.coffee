class MagicOrders.Views.TradesBatchSortProduct extends Backbone.View

  template: JST['trades/batch_sort_product']

  events:
    'click #sort_product_button'  : 'sort_product_search'
    'page-clicked #paginate_skus' : 'sort_product_search'

  initialize: ->
    @collection.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  sort_product_search: (e) ->
    e.preventDefault()
    sort_product_form = $("#sort_product_search_form")
    column_key = sort_product_form.find('select[name="column_key"]').val()
    column_value = sort_product_form.find('input[name="column_value"]').val()
    category_name = sort_product_form.find('select[name="category"]').val()
    if $(e.currentTarget).attr('id') == 'sort_product_button'
      page = 1
    else
      page = $("#paginate_skus").bootstrapPaginator("getPages").current
    datas = {ids: MagicOrders.idCarrier, page: page}
    datas["search"] = {}
    datas["search"]["category"] = category_name if category_name != ""
    datas["search"][column_key] = column_value if column_value != ""
    print_href = '/api/trades/sort_product_search.html?'+$.param(datas)
    $('.print_sorted_product').attr('href', print_href)
    $.get '/api/trades/sort_product_search', datas, (data) ->
      options =
        currentPage: page
        totalPages: data.total_page
      $("#paginate_skus").bootstrapPaginator(options)
      $('#sort_product tbody').html(picking_orders(data.skus))

  picking_orders = (skus) ->
    html = ''
    for sku in skus
      html += '<tr>'
      html += '<td>' + sku.title + '</td>'
      html += '<td>' + sku.num_iid + '</td>'
      html += '<td>' + sku.category + '</td>'
      html += '<td>' + sku.sku_properties + '</td>'
      html += '<td>' + sku.num + '</td>'
      html += '</tr>'
    return html