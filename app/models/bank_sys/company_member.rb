# 企業担当者
class BankSys::CompanyMember
  include JobDb::Model::Member
  include Cms::SitePermission

  set_permission_name "bank_sys_members", :edit
end
