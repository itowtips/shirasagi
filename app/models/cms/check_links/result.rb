class Cms::CheckLinks::Result
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::GroupPermission

  set_permission_name "cms_check_links_error"

  seqid :id

  has_many :errors, foreign_key: "result_id", class_name: "Cms::CheckLinks::Error", dependent: :destroy
end
