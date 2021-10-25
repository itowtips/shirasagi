class Member::Agents::Nodes::PippiMypageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter

  helper Member::BookmarkHelper

  def index
    @item = @cur_member
    @mypage = @cur_node

    @profile_node = Member::Node::PippiProfile.site(@cur_site).first
    @bookmark_node = Member::Node::Bookmark.site(@cur_site).first

    @cur_member.squish_bookmarks
    set_blog_bookmarks
    set_event_bookmarks
    set_other_bookmarks
    @cur_node = @mypage
  end

  def set_blog_bookmarks
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = @mypage.blog_context
    cond = @cur_node.condition_hash(site: @cur_site, node: @cur_node)
    @blog_bookmark_page_ids = Cms::Page.unscoped.where(cond).distinct(:id).to_a
    @blog_bookmark_cond = {
      '$and' => [
        { content_type: /::Page$/ },
        { content_id: { '$in' => @blog_bookmark_page_ids } }
      ]
    }
    @blog_bookmarks = @cur_member.bookmarks.and_public.
      where(@blog_bookmark_cond).limit(@cur_node.limit).to_a
  end

  def set_event_bookmarks
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = @mypage.event_context
    cond = @cur_node.condition_hash(site: @cur_site, node: @cur_node)
    @event_bookmark_page_ids = Cms::Page.unscoped.where(cond).distinct(:id).to_a
    @event_bookmark_cond = {
      '$and' => [
        { content_type: /::Page$/ },
        { content_id: { '$in' => @event_bookmark_page_ids } }
      ]
    }
    @event_bookmarks = @cur_member.bookmarks.and_public.
      where(@event_bookmark_cond).limit(@cur_node.limit).to_a
  end

  def set_other_bookmarks
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = @mypage.bookmark_context
    @other_bookmark_cond = {
      '$or' => [
        { content_type: /::Node$/ },
        { content_id: { '$nin' => (@blog_bookmark_page_ids + @event_bookmark_page_ids) } }
      ]
    }
    @other_bookmarks = @cur_member.bookmarks.and_public.
      where(@other_bookmark_cond).limit(@cur_node.limit).to_a
  end
end
