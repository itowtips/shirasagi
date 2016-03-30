require 'rss'

class Rss::ImportJob < Rss::ImportBase
  class << self
    def register_jobs(site, user = nil)
      Rss::Node::Page.site(site).and_public.each do |node|
        register_job(site, node, user)
      end
    end

    def register_job(site, node, user = nil)
      if node.try(:rss_refresh_method) == Rss::Node::Page::RSS_REFRESH_METHOD_AUTO
        call_async(site.host, node.id, user.present? ? user.id : nil) do |job|
          job.site_id = site.id
          job.user_id = user.id if user.present?
        end
      else
        Rails.logger.info("node `#{node.filename}` is prohibited to update")
      end
    end
  end

  private
    def before_import(host, node, user)
      super

      @cur_site = Cms::Site.find_by(host: host)
      return unless @cur_site
      @cur_node = Rss::Node::Page.site(@cur_site).and_public.or({id: node}, {filename: node}).first
      return unless @cur_node
      @cur_user = Cms::User.site(@cur_site).or({id: user}, {name: user}).first if user.present?

      begin
        @items = Rss::Wrappers.parse(@cur_node.rss_url, @cur_node.rss_url_options)
      rescue => e
        Rails.logger.info("Rss::Wrappers.parse failer (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
        @items = nil
      end
    end

    def after_import
      super
    end
end
