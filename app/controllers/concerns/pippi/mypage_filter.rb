module Pippi::MypageFilter
  extend ActiveSupport::Concern

  def set_pippi_mypage_contents
    @cur_member.squish_bookmarks
    @item = @cur_member

    set_implicit_nodes

    cur_node = @cur_node
    set_blog_bookmarks(@mypage_node.blog_context)
    set_event_bookmarks(@mypage_node.event_context)
    set_other_bookmarks(@mypage_node.bookmark_context)
    @cur_node = cur_node
  end

  def set_implicit_nodes
    @mypage_node = Member::Node::PippiMypage.site(@cur_site).first
    @profile_node = Member::Node::PippiProfile.site(@cur_site).first
    @bookmark_node = Member::Node::Bookmark.site(@cur_site).first
  end

  def set_blog_bookmarks(context)
    @blog_bookmarks = []
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = context
    cond = @cur_node.condition_hash(site: @cur_site, node: @cur_node)
    @blog_bookmark_page_ids = Cms::Page.unscoped.where(cond).distinct(:id).to_a
    @blog_bookmark_cond = {
      '$and' => [
        { content_type: /::Page$/ },
        { content_id: { '$in' => @blog_bookmark_page_ids } }
      ]
    }
    @blog_bookmarks = @cur_member.bookmarks.and_public.where(@blog_bookmark_cond)
  end

  def set_event_bookmarks(context)
    @event_bookmarks = []
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = context
    cond = @cur_node.condition_hash(site: @cur_site, node: @cur_node)
    @event_bookmark_page_ids = Cms::Page.unscoped.where(cond).distinct(:id).to_a
    @event_bookmark_cond = {
      '$and' => [
        { content_type: /::Page$/ },
        { content_id: { '$in' => @event_bookmark_page_ids } }
      ]
    }
    @event_bookmarks = @cur_member.bookmarks.and_public.where(@event_bookmark_cond)
  end

  def set_other_bookmarks(context)
    @other_bookmarks = []
    return unless @bookmark_node
    @cur_node = @bookmark_node
    @cur_node.attributes = context
    @other_bookmark_cond = {
      '$or' => [
        { content_type: /::Node$/ },
        { content_id: { '$nin' => (@blog_bookmark_page_ids + @event_bookmark_page_ids) } }
      ]
    }
    @other_bookmarks = @cur_member.bookmarks.and_public.where(@other_bookmark_cond)
  end
end
