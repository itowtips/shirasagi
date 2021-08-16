class Member::Agents::Nodes::FavoritePageController < ApplicationController
  include Cms::NodeFilter::View
  include Member::AuthFilter

  protect_from_forgery except: [:index]

  def index
    @cur_member = get_member_by_session rescue nil

    path = params[:path]
    raise "404" if path.blank?

    path = path.sub(/^\//, "")
    page = Cms::Page.where(filename: path).first

    if page
      cond = { site_id: @cur_site.id, member_id: @cur_member.id, page_id: page.id }
      Member::Bookmark.find_or_create_by(cond)
    end

    #Member::Bookmark.site(@cur_site)
    #find_or_initialize_by(cond)
  end
end
