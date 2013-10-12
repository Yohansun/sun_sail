module MagicOrder
  module APIHelpers
    def current_account
      @current_account ||= if params[:private_token].nil?
        nil
      else
        ThirdParty.find_by_authentication_token(params[:private_token] || env["HTTP_PRIVATE_TOKEN"])
      end
    end

    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end

    def paginate(object)
      object.page(params[:page]).per(params[:per_page] || 100)
    end

    def authenticate!
      unauthorized! unless current_account
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def render_api_error!(message, status)
      error!({'message' => message}, status)
    end

    private
    def content_types
      Grape::ContentTypes.content_types_for(settings[:content_types])
    end

    # parameters format=json will be set 'Content-Type' of headers
    def set_content_type
      format = settings[:format] = params[:format].to_sym
      content_type content_types[format]
    end
  end
end