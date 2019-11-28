class Translate::Mock
  class << self
    def translate(contents, from, to)
      dump(contents)
      contents.map { |content| "[tr:" + content + "]" }
    end
  end
end
