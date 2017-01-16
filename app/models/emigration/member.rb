class Emigration::Member
  include JobDb::Model::Member
  include Cms::SitePermission

  set_permission_name "emigration_members", :edit
end
