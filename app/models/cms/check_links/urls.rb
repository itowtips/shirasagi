class Cms::CheckLinks::Urls
  attr_accessor :site
  attr_accessor :urls, :results, :errors

  def initialize(site)
    @site = site
    @urls = { site.url => %w(Site) }
    @results = {}
    @errors  = {}
  end

  def next
    @urls.shift
  end

  def add_next()

  end
end
