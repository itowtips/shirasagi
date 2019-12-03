class Translate::MicrosoftTranslator

  def initialize(site, opts = {})
    @key = key
    @url = url
  end

  def translate(texts, from, to)
    uri = URI(@url + "&from=#{from}&to=#{to}")

    request = Net::HTTP::Post.new(uri)
    request['Content-type'] = 'application/json'
    request['Content-length'] = content.length
    request['Ocp-Apim-Subscription-Key'] = @key
    request['X-ClientTraceId'] = SecureRandom.uuid
    request.body = content

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    result = response.body.force_encoding("utf-8")
    json = JSON.parse(result)

    p json

    # TODO : catch error
    if json.kind_of?(Hash) && json["error"]
      #
    else
      #
    end
  end
end
