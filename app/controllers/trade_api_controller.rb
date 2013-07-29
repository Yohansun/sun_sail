# -*- encoding : utf-8 -*-
class TradeApiController < ApplicationController
  include WashOut::SOAP

  skip_before_filter :verify_authenticity_token, :authenticate_user!
  soap_action "query_success_trades", args: {login: :string, passwd: :string, end_time_start: :string, end_time_end: :string, trade_source_id: :string}, return: :string

  # client = Savon.client(wsdl: 'http://magic.dev/trade_api/wsdl')
  # response = client.call(:query_success_trades, message:{login: 'replacemelater', passwd: 'replacemelater', end_time_start: '2013-06-01 00:00:00 UTC', end_time_end: '2013-06-30 23:59:59 UTC', trade_source_id: '201'})
  # response.body[:query_success_taobao_trades_response]

  # 查询交易成功(支付宝到账)
  def query_success_trades
    if (params[:login] && params[:passwd] && params[:trade_source_id] && params[:end_time_start] && params[:end_time_end])
      if params[:login] == 'replacemelater' && params[:passwd] == 'replacemelater'
        trades = Trade.where(trade_source_id: params[:trade_source_id])
        success_trades = trades.where(status: 'TRADE_FINISHED')
        end_time_start = params[:end_time_start].to_time(:local) rescue nil
        end_time_end = params[:end_time_end].to_time(:local) rescue nil
        if end_time_start && end_time_end
          expected_trades = success_trades.where(end_time: end_time_start..end_time_end)
          expected_trades = TradeDecorator.decorate(expected_trades)
          if expected_trades.count > 0
            result = Api::Trades.xml(expected_trades)
            render soap: result
          else
            render soap: "没有数据可以提供"
          end
        else
          render soap: "开始时间和结束时间不合法"
        end
      else
        render soap: "账号密码不正确"
      end
    else
      render soap: "账号,密码,开始时间,结束时间,订单源为必填项"
    end
  end

  before_filter :dump_parameters
  def dump_parameters
    Rails.logger.debug params.inspect
  end
end