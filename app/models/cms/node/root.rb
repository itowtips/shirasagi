class Cms::Node::Root
  include ActiveModel::Model
  #include SS::Reference::Site

  attr_accessor :cur_site
  attr_accessor :site_id

  public
    def initialize(cur_site)
      self.cur_site = cur_site
      self.site_id = cur_site
    end

    def id
      _id
    end

    def _id
      0
    end

    def site
      cur_site
    end

    def name
      "root"
    end

    def filename
      ""
    end

    def depth
      0
    end

    def route
      "cms/node"
    end

    def view_route
      "cms/node"
    end

    def path
      "#{site.path}"
    end

    def parents
      Cms::Node.where(site_id: site_id, filename: nil) #return empty
    end

    def parent
      @parent = nil #parents.first
    end

    def nodes
      Cms::Node.where(site_id: site_id)
    end

    def children(cond = {})
      nodes.where cond.merge(depth: depth + 1)
    end

    def pages
      Cms::Page.where(site_id: site_id)
    end

    def parts
      Cms::Part.where(site_id: site_id)
    end

    def layouts
      Cms::Layout.where(site_id: site_id)
    end

    def allowed?(action, user, opts = {})
      return true
    end

    def layout_id
      nil
    end

    def page_layout_id
      nil
    end

    def new_record?
      false
    end

    def becomes_with_route
      self
    end

    def owned?(user)
      return true
    end

    class << self
      public
        def allow(action, user, opts = {})
          where({})
        end

        def allowed?(action, user, opts = {})
          return true
        end
      end
end
