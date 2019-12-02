class Translate::Mock
  class << self
    def translate(contents, source, target)
      contents.map { |content| "[#{target}:" + content + "]" }
    end
  end
end
