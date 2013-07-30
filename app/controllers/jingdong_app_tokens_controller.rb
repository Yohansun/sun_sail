# -*- encoding : utf-8 -*-
class JingdongAppTokensController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    #info = auth_hash['info']
    render text: auth_hash
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end