class Recommend::CreateRandomLogJob < Cms::ApplicationJob
  def perform(opts = nil)
    pages = Cms::Page.site(site).where(filename: /^docs\//).map(&:url)
    #nodes = Cms::Node.site(site).map(&:url)
    contents = pages

    10.times do
      token = nil
      30.times do
        path = contents.sample
        log = Recommend::History::Log.new(token: token, path: path, access_url: path, site: site)
        log.save
        token = log.token
        puts "#{token} #{log.full_url}"
      end
    end
  end
end
