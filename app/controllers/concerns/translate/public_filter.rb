module Translate::PublicFilter
  extend ActiveSupport::Concern

  included do
    after_action :render_translate, if: ->{ filters.include?(:translate) }
  end

  private

  def set_request_path_with_translate
    return if @cur_main_path !~ /^\/translate\//
    @cur_main_path.sub!(/^\/translate\//, "/")
    filters << :translate
  end

  def render_translate
    cache = Translate::HtmlCache.site(@cur_site).where(url: @cur_main_path, lang: "en").first
    if cache
      dump("translate found : #{@cur_main_path}")
      response.body = cache.html
    else
      dump("translate not found: #{@cur_main_path}")
      #
    end
  end
end
