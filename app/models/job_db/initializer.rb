module JobDb
  class Initializer
    # login node
    Cms::Node.plugin "job_db/login"

    # permissions
    Sys::Role.permission :edit_job_db_members, module_name: "job_db"
    Sys::Role.permission :read_job_db_companies, module_name: "job_db"
    Sys::Role.permission :edit_job_db_companies, module_name: "job_db"
    Sys::Role.permission :delete_job_db_companies, module_name: "job_db"
    Sys::Role.permission :release_job_db_companies, module_name: "job_db"
  end
end
