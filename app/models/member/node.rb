module Member::Node
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

    default_scope ->{ where(route: "member/login") }
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

  class Blog
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/blog") }

    public
      def page_url(blog, page)
        "#{url}#{blog.id}/page/#{page.id}/"
      end
  end
end
