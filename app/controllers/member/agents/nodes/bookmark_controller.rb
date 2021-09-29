class Member::Agents::Nodes::BookmarkController < ApplicationController
  include Cms::NodeFilter::View
  include Member::AuthFilter

  protect_from_forgery except: [:index]

  def index
    raise "404" unless member_login_path

    path = params[:path]
    raise "404" if path.blank?

    @cur_member = get_member_by_session rescue nil
    if @cur_member.nil?
      redirect_to "#{member_login_path}?ref=#{CGI.escape(path)}"
      return
    end

    filename = path.delete_prefix(@cur_site.url)
    page = Cms::Page.site(@cur_site).where(filename: filename).first
    raise "404" if page.nil?

    cond = { site_id: @cur_site.id, member_id: @cur_member.id, page_id: page.id }
    Member::Bookmark.find_or_create_by(cond)
    redirect_to "#{page.url}?registered_favorite=1"
  end
end
