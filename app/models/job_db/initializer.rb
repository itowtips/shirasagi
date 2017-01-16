module JobDb
  class Initializer
    Sys::Role.permission :edit_job_db_members, module_name: "job_db"
    Sys::Role.permission :edit_job_db_companies, module_name: "job_db"
  end
end
