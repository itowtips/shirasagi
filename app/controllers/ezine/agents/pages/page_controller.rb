class Ezine::Agents::Pages::PageController < ApplicationController
  include Cms::PageFilter::View

  def index
    if params[:lang]
      lang = @cur_page.translate_targets.select{ |target| target.code == params[:lang] }.first
      if lang.present?
        @cur_page.name = @cur_page.i18n_name_translations[lang.code]
        @cur_page.html = @cur_page.i18n_html_translations[lang.code]
        @cur_page.text = @cur_page.i18n_text_translations[lang.code]
      end
    end
  end
end
