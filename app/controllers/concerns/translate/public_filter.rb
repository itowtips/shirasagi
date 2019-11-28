module Translate::PublicFilter
  extend ActiveSupport::Concern

  included do
    after_action :render_translate, if: ->{ filters.include?(:translate) }
  end

  private

  def set_request_path_with_translat
    return if @cur_main_path !~ /^\/translate\/.+?\//

    main_path = @cur_main_path.sub(/^\/translate\/(.+?)\//, "/")
    @translate_target = ::Regexp.last_match[1]
    @translate_source = @cur_site.translate_source_language_code
    @translate_location = "translate/#{@translate_target}"

    if @cur_site.translate_target_language_codes.include?(@translate_target)
      filters << :translate
      @cur_main_path = main_path
    end
  end

  def translatable?(text)
    return false if text =~ EmailValidator::REGEXP
    return false if text =~ /\A#{URI::regexp(%w(http https))}\z/
    return false if text =~ /\A[#{I18n.t("translate.ignore_character")}]\z/
    true
  end

  def render_translate
    body = response.body

    if params[:format] == "json"
      body = ActiveSupport::JSON.decode(body)
    end

    if body =~ /<html.*>/m
      partial = false
    else
      body = "<html><body>" + body + "</body></html>"
      partial = true
    end

    doc = Nokogiri.parse(body)

    # links
    doc.css('body a,body form').each do |node|
      href = node.attributes["href"]
      action = node.attributes["action"]

      if href.present?
        node.attributes["href"].value = href.value.gsub(/^#{@cur_site.url}(?!#{@translate_location}\/)(?!fs\/)/, "#{@cur_site.url}#{@translate_location}/")
      end
      if action.present?
        node.attributes["action"].value = action.value.gsub(/^#{@cur_site.url}(?!#{@translate_location}\/)(?!fs\/)/, "#{@cur_site.url}#{@translate_location}/")
      end
    end

    nodes = []
    doc.search('//text()').each do |node|
      next if node.node_type != 3
      next if node.blank?

      text = node.content.gsub(/(^[[:space:]]+)|([[:space:]]+$)/, '')
      next if !translatable?(text)

      nodes << node
    end

    item = Translate::RequestBuffer.new(@cur_site, @translate_source, @translate_target)
    nodes.each do |node|
      text = node.content
      item.push text, node
    end
    item.translate.each do |node, caches|
      node.content = caches.map { |caches| caches.text }.join("\n")
    end

    if partial
      body = doc.css("body").inner_html
      body.delete!("<html>", "")
      body.delete!("</html>", "")
    else
      body = doc.to_s
      body.sub!(/<body( |>)/m, '<body data-translate="true"\\1')
    end

    if params[:format] == "json"
      body = ActiveSupport::JSON.encode(body)
    end

    response.body = body
  end
end
