class Translate::RequestBuffer
  attr_reader :translated, :caches
  attr_reader :source, :target
  attr_reader :request_count, :request_word_count

  def initialize(site, source, target, opts = {})
    @site = site
    @api = Translate::Mock
    @source = source
    @target = target

    @array_size_limit = SS.config.translate.mock_api["array_size_limit"]
    @text_size_limit = SS.config.translate.mock_api["text_size_limit"]
    @contents_size_limit = SS.config.translate.mock_api["contents_size_limit"]
    @interval = SS.config.translate.mock_api["interval"]

    @array_size_limit = opts[:array_size_limit] if opts[:array_size_limit]
    @text_size_limit = opts[:text_size_limit] if opts[:text_size_limit]
    @contents_size_limit = opts[:contents_size_limit] if opts[:contents_size_limit]
    @interval = opts[:interval] if opts[:interval]

    reset_result
    reset_buffer
  end

  def reset_buffer
    @caches = []
    @requests = []
    @contents = []
    @contents_size = 0
  end

  def reset_result
    @translated = {}
    @request_count = 0
    @request_word_count = 0
  end

  def requests
    @contents.present? ? (@requests + [@contents]) : @requests
  end

  def find_cache(text, key)
    cond = { site_id: @site.id, original_text: text, api: "mock", source: @source, target: @target }
    item = Translate::TextCache.find_or_create_by(cond)
    item.key = key
    item
  end

  def push(text, key)
    text = text.to_s.strip
    texts = text.scan(/.{1,#{@text_size_limit}}/)
    caches = texts.map { |text| find_cache(text, key) }

    cache_ids = []
    caches.each do |cache|
      @caches << cache
      next if cache.text.present?
      next if cache_ids.include?(cache.id.to_s)

      cache_ids << cache.id.to_s
      size = cache.original_text.size

      if @contents.size >= @array_size_limit
        @requests << @contents
        @contents = []
        @contents_size = 0
      elsif (@contents_size + size) > @contents_size_limit
        @requests << @contents
        @contents = []
        @contents_size = 0
      end

      @contents_size += size
      @contents << cache
    end
  end

  def translate
    reset_result

    requests.each do |contents|
      texts = contents.map { |cache| cache.original_text }
      translated = @api.translate(texts, "ja", "en")
      @request_count += 1
      @request_word_count += texts.map(&:size).sum
      sleep @interval

      contents.each_with_index do |cache, i|
        cache.text = translated[i]
        cache.save!
      end
    end

    @site.translate_request_count += @request_count
    @site.translate_request_word_count += @request_word_count
    @site.update!

    @caches.each do |cache|
      if cache.text.blank?
        cache.reload
      end

      @translated[cache.key] ||= []
      @translated[cache.key] << cache
    end

    reset_buffer

    @translated
  end
end
