class JobDb::Member
  include SS::Model::Member
  include Sys::Permission
  include JobDb::Addon::Member::Applicant

  store_in collection: "job_db_members"
  set_permission_name "job_db_members", :edit
end
