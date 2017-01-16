# 求職者
class BankSys::JobSeeker
  include JobDb::Model::Member
  include Cms::SitePermission

  set_permission_name "bank_sys_members", :edit
end
