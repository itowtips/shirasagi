class Translate::HtmlCache
  include SS::Document
  include SS::Reference::Site

  field :name, type: String
  field :url, type: String
  field :api, type: String
  field :target_id, type: String
  field :target_class, type: String
  field :lang, type: String

  field :html, type: String, default: ""
  field :translated, type: DateTime

  validates :name, presence: true
  validates :url, presence: true
  validates :api, presence: true
  validates :target_id, presence: true
  validates :target_class, presence: true
  validates :lang, presence: true

  def create_translate(to)
    cache = self.class.where(url: url, lang: to).first
    cache ||= self.class.new
    cache.site = site
    cache.name = name
    cache.url = url
    cache.target_id = target_id
    cache.target_class = target_class
    cache.lang = to

    doc = Nokogiri.parse(html)

    text_nodes = []
    doc.search('//text()').each do |text_node|
      text = text_node.content
      next if text =~ /^\s*$/

      text_nodes << text_node
    end

    translator = Translate::MsTranslator.new
    text_nodes.each do |text_node|
      text = text_node.content
      translator << text
    end

    translated = translator.translate(lang, to)
    text_nodes.each_with_index do |text_node, i|
      text_node.content = translated[i]
    end

    cache.html = doc.to_s
    cache
  end
end
