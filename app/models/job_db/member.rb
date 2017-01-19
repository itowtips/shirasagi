class JobDb::Member
  include JobDb::Model::Member
  include JobDb::Addon::GroupPermission

  set_permission_name "job_db_members"
end
