class Facility::Map
  include ::Cms::Model::Page
  include ::Workflow::Addon::Approver
  include ::Cms::Addon::Meta
  include ::Map::Addon::Page
  include ::Cms::Addon::Release
  include ::Cms::Addon::ReleasePlan
  include ::Cms::Addon::GroupPermission

  set_permission_name "facility_pages"

  default_scope ->{ where(route: "facility/map") }

  before_save :seq_filename, if: ->{ basename.blank? }

  after_save :update_parent_node
  after_destroy :update_parent_node

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

    def update_parent_node
      node = parent.becomes_with_route
      node.cur_user = cur_user
      node.update
    end
end
