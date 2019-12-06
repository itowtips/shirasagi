# ref : https://github.com/MicrosoftTranslator/Text-Translation-API-V3-Ruby/blob/master/Translate.rb

class Translate::Api::MicrosoftTranslator
  attr_reader :site, :key, :url, :count, :metered_usage

  def initialize(site, opts = {})
    @site = site
    @count = 0
    @metered_usage = 0

    @key = SS.config.translate.microsoft_translator_text["key"]
    @url = SS.config.translate.microsoft_translator_text["url"]
    if @site.translate_microsoft_api_key.present?
      @key = @site.translate_microsoft_api_key
    end

    @key = opts[:key] if opts[:key]
    @url = opts[:url] if opts[:url]

    @logger = Logger.new('log/translate_api.log', 'daily')
    @logger.level = SS.config.translate.mock["log_level"]
    @logger.level = opts[:log_level] if opts[:log_level]
  end

  def put_log(log_level, message)
    if log_level == :error
      @logger.send(log_level, message)
      Rails.logger.send(log_level, message)
    else
      @logger.send(log_level, message)
    end
  end

  def put_request(log_level, request)
    put_log log_level, "request header : #{request.to_json}"
    put_log log_level, "request body : #{request.body}"
  end

  def put_response(log_level, response)
    put_log log_level, "response header : #{response.to_json}"
    put_log log_level, "response body : #{response.body}"
  end

  def translate(texts, from, to, opts = {})
    translated = texts
    @count = texts.map(&:size).sum
    @metered_usage = 0

    uri = URI(@url + "&from=#{from}&to=#{to}")
    content = texts.map { |text| { "Text" => text } }.to_json

    request = Net::HTTP::Post.new(uri)
    request['Content-type'] = 'application/json'
    request['Content-length'] = content.length
    request['Ocp-Apim-Subscription-Key'] = @key
    request['X-ClientTraceId'] = SecureRandom.uuid
    request.body = content

    put_log :info, "Start translate with MicrosoftTranslatorText api"
    put_request :info, request

    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        http.request(request)
      end
    rescue Timeout::Error
      put_log :error, "MicrosoftTranslatorText Api : Timeout error"
    else
      result = response.body.force_encoding("utf-8")
      json = JSON.parse(result)

      if response["x-metered-usage"].present?
        @metered_usage = response["x-metered-usage"].to_i
      end

      if response.code == "200"
        put_response :info, response
        translated = json.map { |item| ::CGI.unescapeHTML(item["translations"][0]["text"]) }
      else
        put_log :error, "MicrosoftTranslatorText Api : #{response.code} error"
        put_response :error, response
      end
    end

    @logger.info("Completed translate #{count} characters")

    site = opts[:site]
    if site
      site.translate_microsoft_api_request_count += 1
      site.translate_microsoft_api_request_metered_usage += @metered_usage
      site.translate_microsoft_api_request_word_count += @count
    end

    translated
  end
end
