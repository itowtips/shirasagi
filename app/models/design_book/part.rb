class DesignBook::Part
  include Cms::Model::Part
  include Cms::PluginRepository

  index({ site_id: 1, filename: 1 }, { unique: true })

  plugin_type "part"

  class Base
    include Cms::Model::Part

    default_scope ->{ where(route: /^design_book\//) }
  end

  class Search
    include Cms::Model::Part
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "design_book/search") }

    def find_search_node
      # first, look parent
      parent = self.parent
      return parent if parent.route == 'design_book/page'

      # second, lookup siblings node
      DesignBook::Node::Page.site(self.site).and_public.
          where(filename: /^#{::Regexp.escape(parent.filename)}/, depth: self.depth).first
    end

    def search_url
      find_search_node.try(:url)
    end
  end
end
