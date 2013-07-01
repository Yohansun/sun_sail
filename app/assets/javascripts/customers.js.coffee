AmCharts.build = (chartData) ->
#  // SERIAL CHART
  chart = new AmCharts.AmSerialChart()
  chart.dataProvider = chartData
  chart.categoryField = "priceLevels"
  chart.startDuration = 1
  chart.marginTop = 40

#  // AXES
#  // category
  categoryAxis = chart.categoryAxis
  categoryAxis.title = "购买时间"
  categoryAxis.titleColor = "#555555"
  categoryAxis.gridAlpha = 0.15
  categoryAxis.fillAlpha = 1
  categoryAxis.axisColor = "#DADADA"
  categoryAxis.gridPosition = "start"


#  // value
  valueAxis = new AmCharts.ValueAxis
  valueAxis.dashLength = 5
  valueAxis.title = "购买金额"
  valueAxis.titleColor = "#555555"
  valueAxis.unit = "(元)"
  valueAxis.axisAlpha = 0
  chart.addValueAxis(valueAxis)

#  // GRAPH
  graph = new AmCharts.AmGraph()
  graph.valueField = "visits"
  graph.colorField = "color"
  graph.balloonText = "[[category]]: [[value]]"
  graph.type = "column"
  graph.lineAlpha = 0
  graph.fillAlphas = 0.7
  chart.addGraph(graph)

#  // WRITE
  chart.write("chartdiv")