class JobNavi::Member
  include JobDb::Model::Member
  include Cms::SitePermission

  set_permission_name "job_navi_members", :edit
end
