class JobDb::Member
  include JobDb::Model::Member
  include Sys::Permission

  set_permission_name "job_db_members", :edit
end
