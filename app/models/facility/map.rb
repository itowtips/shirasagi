class Facility::Map
  include ::Cms::Model::Page
  include ::Workflow::Addon::Approver
  include ::Cms::Addon::Meta
  include ::Map::Addon::Page
  include ::Cms::Addon::Release
  include ::Cms::Addon::ReleasePlan
  include ::Cms::Addon::GroupPermission

  default_scope ->{ where(route: "facility/map") }

  before_save :seq_filename, if: ->{ basename.blank? }

  after_save :update_parent_node

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
      parent.becomes_with_route.update
    end
end
