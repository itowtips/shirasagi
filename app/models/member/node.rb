module Member::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^member\//) }
  end

  class Login
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Member::Addon::Redirection
    include Member::Addon::FormAuth
    include Member::Addon::TwitterOauth
    include Member::Addon::FacebookOauth
    include Member::Addon::YahooJpOauth
    include Member::Addon::GoogleOauth
    include Member::Addon::GithubOauth
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/login") }
  end

  class Mypage
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/mypage") }

    public
      def children
        Member::Node::Base.public.
          where(filename: /^#{filename}\//, depth: depth + 1).
          order_by(order: 1)
      end
  end

  class MyProfile
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/my_profile") }
  end

  class MyBlog
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/my_blog") }

    public
      def setting_url
        "#{url}setting/"
      end

      def blog(member)
        Member::Blog.where(site_id: site.id, member_id: member.id).first
      end
  end

  class MyPhoto
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/my_photo") }
  end

  class Blog
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    template_variable_handler "description", :template_variable_handler_description
    template_variable_handler "contributor", :template_variable_handler_contributor

    default_scope ->{ where(route: "member/blog") }

    public
      def sort_hash
        return { created: -1 } if sort.blank?
        super
      end

      def layout_options
        Member::BlogLayout.where(filename: /^#{filename}\//).
          map { |item| [item.name, item.id] }
      end

    private
      def template_variable_handler_description(item, name)
        item.description
      end

      def template_variable_handler_contributor(item, name)
        item.contributor
      end
  end

  class BlogPage
    include Cms::Model::Node
    include Cms::Reference::Member
    include Member::Addon::Blog::Setting
    include Cms::Addon::GroupPermission

    set_permission_name "member_blogs"

    default_scope ->{ where(route: "member/blog_page") }

    before_validation ->{ self.page_layout = layout }

    public
      def html
        ## for loop html img summary
        %(<img alt="#{name}" src="#{thumb_url}">) rescue ""
      end

      def pages
        Member::BlogPage.where(filename: /^#{filename}\//, depth: depth + 1).public
      end
  end

  class Photo
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo") }
  end

  class PhotoSearch
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_search") }
  end

  class PhotoSpot
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_spot") }
  end

  class PhotoCategory
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_category") }

    def condition_hash
      cond = []
      cids = []

      cids << id
      conditions.each do |url|
        node = Cms::Node.filename(url).first
        next unless node
        cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
        cids << node.id
      end
      cond << { :photo_category_ids.in => cids } if cids.present?

      { '$or' => cond }
    end
  end

  class PhotoLocation
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_location") }

    def condition_hash
      cond = []
      cids = []

      cids << id
      conditions.each do |url|
        node = Cms::Node.filename(url).first
        next unless node
        cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
        cids << node.id
      end
      cond << { :photo_location_ids.in => cids } if cids.present?

      { '$or' => cond }
    end
  end
end
