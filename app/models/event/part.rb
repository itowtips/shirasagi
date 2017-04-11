module Event::Part
  class Calendar
    include Cms::Model::Part
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "event/calendar") }
  end

  class Search
    include Cms::Model::Part
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "event/search") }

    def find_search_node
      # first, look parent
      parent = self.parent
      if parent.route == 'event/search'
        return parent.becomes_with_route
      end

      # second, lookup siblings node
      Event::Node::Search.site(self.site).and_public.
        where(filename: /^#{Regexp.escape(parent.filename)}/, depth: self.depth).first
    end

    def search_url
      find_search_node.try(:search_url)
    end

    def cate_ids
      find_search_node.parent.st_category_ids
    end
  end
end
