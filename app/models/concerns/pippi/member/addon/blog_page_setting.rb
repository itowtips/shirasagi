module Pippi::Member::Addon
  module BlogPageSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("blog").call
    end

    def loop_delegates
      delegate = blog_loop_delegate
      delegates = super
      delegates << delegate if delegate
      delegates
    end

    def blog_criteria_proc
      proc do |context|
        site = context.cur_site
        node = context.cur_node
        cond = context.deliver_category_cond
        return Cms::Page.none if cond.blank?
        Cms::Page.public_list(site: site, node: node).where(cond).
          order_by(node.sort_hash).limit(node.limit)
      end
    end
  end
end
