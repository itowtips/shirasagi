class Facility::Map
  include Cms::Model::Page
  include Cms::Page::SequencedFilename
  include Workflow::Addon::Approver
  include Cms::Addon::Meta
  include Map::Addon::Page
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission

  default_scope ->{ where(route: "facility/map") }

  after_save :save_facility_node_page

  private
    def serve_static_file?
      false
    end

    def save_facility_node_page
      node = Facility::Node::Page.site(site).where(filename: ::File.dirname(filename), depth: depth - 1).first
      node.save if node
    end
end
