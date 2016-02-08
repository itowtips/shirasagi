module Member::Part
  class BlogPage
    include Cms::Model::Part
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/blog_page") }

    public
      def condition_hash(opts = {})
        cond = []
        cids = []
        cond_url = []

        cond << { filename: /^#{parent.filename}\// }
        #cids << id
        #cond_url = conditions
        { '$or' => cond }
      end
  end

  class PhotoSearch
    include Cms::Model::Part
    include KeyVisual::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_search") }
  end

  class PhotoSlide
    include Cms::Model::Part
    include KeyVisual::Addon::PageList
    include Member::Addon::Photo::Slide
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "member/photo_slide") }
  end
end
