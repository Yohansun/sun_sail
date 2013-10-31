var Charts = function () {

    return {
      //main function to initiate the module

      init: function () {
        App.addResponsiveHandler(function () {
             Charts.initMiniCharts();
        });
      },

      showTooltip: function (title, x, y, contents, pagex, pagey) {
        $('<div id="tooltip" class="chart-tooltip"><div class="date">' + title + '<\/div><div class="label label-success">CTR: ' + x / 10 + '%<\/div><div class="label label-important">Imp: ' + y + '<\/div><\/div>').css({
          position: 'absolute',
          display: 'none',
          top: pagey - 100,
          width: 75,
          left: pagex - 40,
          border: '0px solid #ccc',
          padding: '2px 6px',
          'background-color': '#fff',
        }).appendTo("body").fadeIn(200);
      },

      randValue: function() {
        return (Math.floor(Math.random() * (1 + 50 - 20))) + 10;
      },

      getRandomData: function (data, total_points) {
        if (data.length > 0) data = data.slice(1);
        // do a random walk
        while (data.length < total_points) {
          var prev = data.length > 0 ? data[data.length - 1] : 50;
          var y = prev + Math.random() * 10 - 5;
          if (y < 0) y = 0;
          if (y > 100) y = 100;
          data.push(y);
        }
        // zip the generated y values with the x values
        var res = [];
        for (var i = 0; i < data.length; ++i) res.push([i, data[i]])
          return res;
      },


      initTradesCharts: function (create_amount, pay_amount) {
        if (!jQuery.plot) {
            return;
        }

        var data = [];
        var totalPoints = 250;

        //销售统计
        if ($('#sale_analysis_block').size() != 0) {

          $('#sale_analysis_block_loading').hide();
          $('#sale_analysis_block_content').show();

          var plot_statistics = $.plot($("#sale_analysis_block"), [{
              data: create_amount,
              label: "下单金额"
          }, {
              data: pay_amount,
              label: "付款金额"
          }
          ], {
              series: {
                  lines: {
                      show: true,
                      lineWidth: 2,
                      fill: true,
                      fillColor: {
                          colors: [{
                              opacity: 0.05
                          }, {
                              opacity: 0.01
                          }
                          ]
                      }
                  },
                  points: {
                      show: true
                  },
                  shadowSize: 2
              },
              grid: {
                  hoverable: true,
                  clickable: true,
                  tickColor: "#eee",
                  borderWidth: 0
              },
              colors: ["#d12610", "#37b7f3", "#52e136"],
              xaxis: {
                  ticks: 11,
                  tickDecimals: 0,
                  mode: "time",
                  timeformat: "%m/%d",
                  tickSize: [3, "day"]
              },
              yaxis: {
                  ticks: 11,
                  tickDecimals: 0
              }
          });

          var previousPoint = null;
          $("#sale_analysis_block").bind("plothover", function (event, pos, item) {
              $("#x").text(pos.x.toFixed(2));
              $("#y").text(pos.y.toFixed(2));
              if (item) {
                  if (previousPoint != item.dataIndex) {
                      previousPoint = item.dataIndex;

                      $("#tooltip").remove();
                      var x = item.datapoint[0].toFixed(2),
                      y = item.datapoint[1].toFixed(2);
                      Charts.showTooltip('', item.pageX, y, 'money', item.pageX, item.pageY);
                  }
              } else {
                  $("#tooltip").remove();
                  previousPoint = null;
              }
          });
        }
      },

      initFrequencyCharts: function (frequency_range) {
        if (!jQuery.plot) {
            return;
        }

        var data = [];
        var totalPoints = 250;

        //购买频次分析
        if ($('#frequency_analysis_block').size() != 0) {

          var previousPoint2 = null;
          $('#frequency_analysis_block_loading').hide();
          $('#frequency_analysis_block_content').show();

          var plot_activities = $.plot(
            $("#frequency_analysis_block"), [{
              data: frequency_range,
              color: "rgba(107,207,123, 0.9)",
              shadowSize: 0,
              bars: {
                show: true,
                lineWidth: 0,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 1
                    }, {
                        opacity: 1
                    }
                    ]
                }
              }
            }
            ], {
                series: {
                    bars: {
                        show: true,
                        barWidth: 0.9
                    }
                },
                grid: {
                    show: true,
                    hoverable: true,
                    clickable: false,
                    autoHighlight: true,
                    borderWidth: 0
                },
                xaxis: {
                  tickFormatter: function (v) {
                    return v + "次";
                  }
                },
                yaxis: {
                    min: 0,
                    max: 800
                }
            }
          );

          $("#frequency_analysis_block").bind("plothover", function (event, pos, item) {
              $("#x").text(pos.x.toFixed(2));
              $("#y").text(pos.y.toFixed(2));
              if (item) {
                  if (previousPoint2 != item.dataIndex) {
                      previousPoint2 = item.dataIndex;
                      $("#tooltip").remove();
                      var x = item.datapoint[0].toFixed(2),
                      y = item.datapoint[1].toFixed(2);
                      //Charts.showTooltip('24 Feb 2013', item.pageX, item.pageY, x);
                  }
              }
          });

          $('#frequency_analysis_block').bind("mouseleave", function () {
              $("#tooltip").remove();
          });
        }
      },

      initTimeCharts: function (time_range) {
        if (!jQuery.plot) {
            return;
        }

        var data = [];
        var totalPoints = 250;

        //购买时段分析
        if ($('#time_analysis_block').size() != 0) {

          var previousPoint2 = null;
          $('#time_analysis_block_loading').hide();
          $('#time_analysis_block_content').show();

          var plot_activities = $.plot(
            $("#time_analysis_block"), [{
              data: time_range,
              color: "rgba(107,207,123, 0.9)",
              shadowSize: 0,
              bars: {
                show: true,
                lineWidth: 0,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 1
                    }, {
                        opacity: 1
                    }
                    ]
                }
              }
            }
            ], {
                series: {
                    bars: {
                        show: true,
                        barWidth: 0.9
                    }
                },
                grid: {
                    show: true,
                    hoverable: true,
                    clickable: false,
                    autoHighlight: true,
                    borderWidth: 0
                },
                xaxis: {
                  tickFormatter: function (v) {
                    return v + ":00";
                  }
                },
                yaxis: {
                    min: 0,
                    max: 70
                }
            }
          );

          $("#time_analysis_block").bind("plothover", function (event, pos, item) {
              $("#x").text(pos.x.toFixed(2));
              $("#y").text(pos.y.toFixed(2));
              if (item) {
                  if (previousPoint2 != item.dataIndex) {
                      previousPoint2 = item.dataIndex;
                      $("#tooltip").remove();
                      var x = item.datapoint[0].toFixed(2),
                      y = item.datapoint[1].toFixed(2);
                      //Charts.showTooltip('24 Feb 2013', item.pageX, item.pageY, x);
                  }
              }
          });

          $('#time_analysis_block').bind("mouseleave", function () {
              $("#tooltip").remove();
          });
        }
      },

      initMiniCharts: function () {

        $('.easy-pie-chart .number.paid_trades_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('yellow')
        });

        $('.easy-pie-chart .number.unpaid_trades_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('green')
        });

        $('.easy-pie-chart .number.undelivered_trades_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('red')
        });

        $('.easy-pie-chart .number.potential_customers_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('yellow')
        });

        $('.easy-pie-chart .number.new_customers_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('green')
        });

        $('.easy-pie-chart .number.familiar_customers_percent').easyPieChart({
            animate: 1000,
            size: 75,
            lineWidth: 3,
            barColor: App.getLayoutColorCode('red')
        });
      },

      initFlowCharts: function () {
        // if (!jQuery.plot) {
        //     return;
        // }

        // var data = [];
        // var totalPoints = 250;

        // if ($('#time_analysis_block').size() == 0) {
        //   //server load
        //   $('#time_analysis_block_loading').hide();
        //   $('#time_analysis_block_content').show();

        //   var updateInterval = 30;
        //   var plot_statistics = $.plot($("#time_analysis_block"), [getRandomData()], {
        //     series: {
        //         shadowSize: 1
        //     },
        //     lines: {
        //         show: true,
        //         lineWidth: 0.2,
        //         fill: true,
        //         fillColor: {
        //             colors: [{
        //                 opacity: 0.1
        //             }, {
        //                 opacity: 1
        //             }
        //             ]
        //         }
        //     },
        //     yaxis: {
        //         min: 0,
        //         max: 100,
        //         tickFormatter: function (v) {
        //             return v + "%";
        //         }
        //     },
        //     xaxis: {
        //         show: false
        //     },
        //     colors: ["#e14e3d"],
        //     grid: {
        //         tickColor: "#a8a3a3",
        //         borderWidth: 0
        //     }
        //   });

        //   function statisticsUpdate() {
        //       plot_statistics.setData([getRandomData()]);
        //       plot_statistics.draw();
        //       setTimeout(statisticsUpdate, updateInterval);

        //   }

        //   statisticsUpdate();

        //   // $('#time_analysis_block').bind("mouseleave", function () {
        //   //     $("#tooltip").remove();
        //   // });
        // }
      }
    };

}();