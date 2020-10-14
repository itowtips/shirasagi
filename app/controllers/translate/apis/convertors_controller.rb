class Translate::Apis::ConvertorsController < ApplicationController
  include Cms::ApiFilter

  def convertor
    body = params[:body]

    if params[:format] == "json"
      body = ActiveSupport::JSON.decode(body)
    end

    translate_source = Translate::Lang.site(@cur_site).where(id: params[:translate_source_id]).first
    translate_target = Translate::Lang.site(@cur_site).where(id: params[:translate_target_id]).first
    convertor = Translate::Convertor.new(@cur_site, translate_source, translate_target)
    body = convertor.convert(body)

    if @cur_site.request_word_limit_exceeded
      render json: { notice: @cur_site.translate_api_limit_exceeded_html }
      return
    end

    if params[:format] == "json"
      body = ActiveSupport::JSON.encode(body)
    end

    render json: { body: body }
  end
end
