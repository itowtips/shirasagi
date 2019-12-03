class Translate::Convertor
  attr_reader :site, :source, :target

  def initialize(site, source, target)
    @site = site
    @source = source
    @target = target
    @location = "translate/#{@target}"
  end

  def translatable?(text)
    return false if text =~ EmailValidator::REGEXP
    return false if text =~ /\A#{URI::regexp(%w(http https))}\z/
    return false if text =~ /\A[#{I18n.t("translate.ignore_character")}]+\z/
    true
  end

  def convert(html)
    return html if html.blank?

    if html =~ /<html.*>/m
      partial = false
    else
      html = "<html><body>" + html + "</body></html>"
      partial = true
    end

    doc = Nokogiri.parse(html)

    # compress
    ::Translate::Compressor.site(@site).each do |compressor|
      doc.css(compressor.css).each do |node|
        text = node.text
        node.children.each(&:remove)
        node.add_child(Nokogiri::XML::Text.new(text, doc))
      end
    end

    # links
    regexp = /^#{@site.url}(?!#{@location}\/)(?!fs\/)/
    location = "#{@site.url}#{@location}/"
    doc.css('body a,body form').each do |node|
      href = node.attributes["href"]
      action = node.attributes["action"]

      if href.present?
        node.attributes["href"].value = href.value.gsub(regexp, location)
      end
      if action.present?
        node.attributes["action"].value = action.value.gsub(regexp, location)
      end
    end

    nodes = []
    doc.search('//text()').each do |node|
      next if node.node_type != 3
      next if node.blank?

      text = node.content.gsub(/[[:space:]]+/, " ").strip
      next if !translatable?(text)

      node.content = text
      nodes << node
    end

    item = Translate::RequestBuffer.new(@site, @source, @target)
    nodes.each do |node|
      text = node.content
      item.push text, node
    end
    item.translate.each do |node, caches|
      node.content = caches.map { |caches| caches.text }.join("\n")
    end

    if partial
      html = doc.css("body").inner_html
      html.delete!("<html>", "")
      html.delete!("</html>", "")
    else
      html = doc.to_s
      html.sub!(/(<html.*?)lang="#{@source}"/, "\\1lang=\"#{@target}\"")
      html.sub!(/<body( |>)/m, '<body data-translate="' + @target + '"\\1')
    end

    html
  end
end
