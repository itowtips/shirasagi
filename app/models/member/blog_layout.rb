class Member::BlogLayout
  include Cms::Model::Layout
  include Cms::Addon::Html
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  store_in collection: "member_blog_layouts"
  set_permission_name "member_blogs"

  index({ site_id: 1, filename: 1 }, { unique: true })

  before_save :seq_filename, if: ->{ basename.blank? }

  private
    def validate_filename
      self.filename = "/"
    end

    def set_depth
      self.depth = 1
    end

    def seq_filename
      self.filename = "#{id}.layout.html"
    end
end
