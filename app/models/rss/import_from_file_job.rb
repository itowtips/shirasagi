require 'rss'

class Rss::ImportFromFileJob < Rss::ImportBase
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

      @items = Rss::Wrappers.parse(@cur_file)
    end

    def after_import
      super

      gc_rss_tempfile
    end

    def gc_rss_tempfile
      return if rand(100) >= 20
      Rss::TempFile.lt(updated: 2.weeks.ago).destroy_all
    end
end
