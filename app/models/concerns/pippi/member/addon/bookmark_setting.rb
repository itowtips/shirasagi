module Pippi::Member::Addon
  module BookmarkSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("bookmark").call
    end

    #def bookmark_criteria_proc
    #  proc do |context|
    #    node = context.cur_node
    #    member = context.cur_member
    #    member.bookmarks.and_public.order_by(node.sort_hash).limit(node.limit)
    #  end
    #end
  end
end
