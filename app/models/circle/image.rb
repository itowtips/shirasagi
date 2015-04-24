class Circle::Image
  include Cms::Model::Page
  include Workflow::Addon::Approver
  include Cms::Addon::Meta
  include Circle::Addon::Image
  include Circle::Addon::ImageInfo
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission

  default_scope ->{ where(route: "circle/image") }

  before_save :seq_filename, if: ->{ basename.blank? }

  set_permission_name "cms_pages"

  private
    def validate_filename
      (@basename && @basename.blank?) ? nil : super
    end

    def seq_filename
      self.filename = dirname ? "#{dirname}#{id}.html" : "#{id}.html"
    end

    def serve_static_file?
      false
    end
end
