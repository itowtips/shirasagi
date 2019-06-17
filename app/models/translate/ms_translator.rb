class Translate::MsTranslator < Array
  attr_reader :api_count
  attr_reader :api_errors

  def initialize
    config = SS.config.translate["microsoft_translator_text_api"]

    @key = config["key"]
    @url = config["url"]
    @request_size_limit = config["request_size_limit"]
    @request_text_array_limit = config["request_text_array_limit"]
    @request_interval = config["request_interval"]

    @api_count = 0
    @api_errors = []
    @requests = []
    @responses = []
  end

  def api
    "microsoft_translator"
  end

  def put_log(message)
    puts(message)
    Rails.logger.warn(message)
  end

  def to_request_content
    self.map { |text| { "Text" => text } }.to_json
  end

  def content_size
    self.map(&:size).sum
  end

  # ref: https://docs.microsoft.com/ja-jp/azure/cognitive-services/translator/reference/v3-0-translate?tabs=curl
  def to_translate_chunks
    chunks = []
    separated = []

    self.each_with_index do |text, i|
      if text.size > @request_size_limit
        text.split("").each_slice(@request_size_limit).to_a.map(&:join).each do |_text|
          _text = Translate::Text.new(_text)
          _text.source_index = i
          separated << _text
        end
      else
        text = Translate::Text.new(text)
        text.source_index = i
        separated << text
      end
    end

    chunk = Translate::MsTranslator.new
    separated.each do |text|
      if chunk.content_size >= @request_size_limit || chunk.size >= @request_text_array_limit
        chunks << chunk
        chunk = Translate::MsTranslator.new
      end
      chunk << text
    end

    chunks << chunk
    chunks
  end

  def translate(from, to)
    return [] if self.blank?

    @api_count = 0
    @api_errors = []

    @requests = []
    @responses = []

    uri = URI(@url + "&from=#{from}&to=#{to}")
    results = []
    to_translate_chunks.each do |chunk|

      content = chunk.to_request_content
      # TODO : count up strictly (https://docs.microsoft.com/ja-jp/azure/cognitive-services/translator/character-counts)
      @api_count += chunk.content_size

      request = Net::HTTP::Post.new(uri)
      request['Content-type'] = 'application/json'
      request['Content-length'] = content.length
      request['Ocp-Apim-Subscription-Key'] = @key
      request['X-ClientTraceId'] = SecureRandom.uuid
      request.body = content
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end
      sleep @request_interval

      @requests << request
      @responses << request

      result = response.body.force_encoding("utf-8")
      json = JSON.parse(result)

      # TODO : catch network error
      if json.kind_of?(Hash) && json["error"]

        put_log "error translate chunk: #{chunk.size} #{chunk.content_size}"
        put_log chunk.to_s
        put_log json["error"]

        @api_errors << json["error"]
      else

        put_log "translate : #{chunk.size} #{chunk.content_size}"

        chunk.each_with_index do |source_text, i|
          result = json[i]
          text = Translate::Text.new(result["translations"].first["text"])
          text.source_index = source_text.source_index
          results << text
        end
      end
    end

    put_log "api_count : #{@api_count}"

    translated = []
    results.each do |text|
      if translated[text.source_index]
        translated[text.source_index] += text
      else
        translated[text.source_index] = text
      end
    end

    translated.each_with_index do |text, i|
      item = Translate::Cache.new
      item.api = api
      item.from = from
      item.to = to
      item.source_text = self[i]
      item.translated_text = text
      item.save!
    end

    translated
  end
end

class Translate::Text < String
  attr_accessor :source_index
end
