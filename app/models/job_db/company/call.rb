# 求人
class JobDb::Company::Call
  extend SS::Translation
  include SS::Document
  include Sys::Permission

  set_permission_name "job_db_companies", :edit
end
