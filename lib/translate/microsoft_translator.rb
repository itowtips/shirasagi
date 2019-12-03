# ref : https://github.com/MicrosoftTranslator/Text-Translation-API-V3-Ruby/blob/master/Translate.rb

class Translate::MicrosoftTranslator
  attr_reader :site, :key, :url

  def initialize(site, opts = {})
    @site = site

    @key = SS.config.translate.microsoft_translator_text["key"]
    @url = SS.config.translate.microsoft_translator_text["url"]

    if @site.translate_microsoft_api_key.present?
      @key = @site.translate_microsoft_api_key
    end

    @key = opts[:key] if opts[:key]
    @url = opts[:url] if opts[:url]

    @logger = Logger.new('log/microsoft_translator_text_api.log')
  end

  def translate(texts, from, to)
    uri = URI(@url + "&from=#{from}&to=#{to}")
    content = texts.map { |text| { "Text" => text } }.to_json

    request = Net::HTTP::Post.new(uri)
    request['Content-type'] = 'application/json'
    request['Content-length'] = content.length
    request['Ocp-Apim-Subscription-Key'] = @key
    request['X-ClientTraceId'] = SecureRandom.uuid
    request.body = content

    dump(content)

    # TODO : catch Timeout
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    result = response.body.force_encoding("utf-8")
    json = JSON.parse(result)

    dump(json)

    if json.kind_of?(Hash) && json["error"]
      Rails.logger.error(json["error"])
      texts
    else
      json.map { |item| item["translations"][0]["text"] }
    end
  end
end
