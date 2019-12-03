class Translate::MockTranslator
  attr_reader :site

  def initialize(site)
    @site = site
  end

  def translate(contents, source, target)
    contents.map { |content| "[#{target}:" + content + "]" }
  end
end
