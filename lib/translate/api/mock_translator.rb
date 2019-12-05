class Translate::Api::MockTranslator
  attr_reader :site, :count

  def initialize(site, opts = {})
    @site = site
    @count = 0

    @logger = Logger.new('log/translate_api.log', 'daily')
    @logger.level = SS.config.translate.mock["log_level"]
    @logger.level = opts[:log_level] if opts[:log_level]
  end

  def translate(contents, source, target, opts = {})
    translated = contents.map { |content| "[#{target}:" + content + "]" }
    @count = contents.map(&:size).sum

    @logger.info("Start translate with mock api")
    @logger.info(contents)
    @logger.info(translated)
    @logger.info("Completed translate #{count} characters")

    site = opts[:site]
    if site
      site.translate_mock_api_request_count += 1
      site.translate_mock_api_request_word_count += @count
    end

    translated
  end
end
