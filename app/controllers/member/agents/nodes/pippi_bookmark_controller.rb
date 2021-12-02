class Member::Agents::Nodes::PippiBookmarkController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter
  include Cms::PublicFilter::FindContent
  include Pippi::MypageFilter

  helper Member::BookmarkHelper

  protect_from_forgery except: [:register, :cancel]

  before_action :logged_in?, if: -> { member_login_path }, only: :index
  before_action :set_path, only: [:register, :cancel]
  before_action :set_member, only: [:register, :cancel]

  private

  def set_path
    @path = params[:path]
    raise "404" if @path.blank?
  end

  def set_member
    raise "404" unless member_login_path
    @cur_member = get_member_by_session rescue nil
    redirect_to "#{member_login_path}?ref=#{CGI.escape(@path)}" if @cur_member.nil?
  end

  public

  def index
    set_pippi_mypage_contents
    if @cur_node.basename =~ /blog/
      @items = @blog_bookmarks
    elsif @cur_node.basename =~ /event/
      @items = @event_bookmarks
    else
      @items = @other_bookmarks
    end
    @items = @items.page(params[:page]).per(@cur_node.limit)
  end

  def register
    item = find_content(@cur_site, @path)
    @cur_member.register_bookmark(item) if item
    redirect_to(params[:ref].presence || @path)
  end

  def cancel
    item = find_content(@cur_site, @path)
    @cur_member.cancel_bookmark(item) if item
    redirect_to(params[:ref].presence || @path)
  end
end
