class Cms::CheckLinks::Error
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::GroupPermission

  set_permission_name "cms_check_links_error"

  belongs_to :result, class_name: "Cms::CheckLinks::Result"
  belongs_to :page, class_name: "Cms::Page"
  belongs_to :node, class_name: "Cms::Node"

  def content
    page || node
  end
end
