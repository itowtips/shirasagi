require 'rss'

class Rss::ImportWeatherXmlJob < Rss::ImportBase
  def initialize(*args)
    super
    set_model Rss::WeatherXmlPage
  end

  private
    def before_import(host, node, user, file)
      super

      @cur_site = Cms::Site.find_by(host: host)
      return unless @cur_site
      @cur_node = Rss::Node::Base.site(@cur_site).and_public.or({id: node}, {filename: node}).first
      return unless @cur_node
      @cur_node = @cur_node.becomes_with_route
      @cur_user = Cms::User.site(@cur_site).or({id: user}, {name: user}).first if user.present?
      @cur_file = Rss::TempFile.where(site_id: @cur_site.id, id: file).first
      return unless @cur_file

      @items = Rss::Wrappers.parse(@cur_file.read)
    end

    def after_import
      super

      gc_rss_tempfile
    end

    def gc_rss_tempfile
      return if rand(100) >= 20
      Rss::TempFile.lt(updated: 2.weeks.ago).destroy_all
    end

    def import_rss_item(*args)
      page = super
      return page if page.nil? || page.invalid?

      content = download(page.rss_link)
      return page if content.nil?

      page.xml = content
      page.save!
      page
    end

    def download(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      req = Net::HTTP::Get.new(uri.path)
      res = http.request(req)
      return nil if res.code != '200'
      res.body
    rescue
      nil
    end
end
