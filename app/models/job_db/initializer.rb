module JobDb
  class Initializer
    #
    # nodes
    #

    # login node
    Cms::Node.plugin "job_db/login"

    #
    # permissions
    #

    # members
    Sys::Role.permission :read_other_job_db_members, module_name: "job_db"
    Sys::Role.permission :read_private_job_db_members, module_name: "job_db"
    Sys::Role.permission :edit_other_job_db_members, module_name: "job_db"
    Sys::Role.permission :edit_private_job_db_members, module_name: "job_db"
    Sys::Role.permission :delete_other_job_db_members, module_name: "job_db"
    Sys::Role.permission :delete_private_job_db_members, module_name: "job_db"

    # companies
    Sys::Role.permission :read_other_job_db_companies, module_name: "job_db"
    Sys::Role.permission :read_private_job_db_companies, module_name: "job_db"
    Sys::Role.permission :edit_other_job_db_companies, module_name: "job_db"
    Sys::Role.permission :edit_private_job_db_companies, module_name: "job_db"
    Sys::Role.permission :delete_other_job_db_companies, module_name: "job_db"
    Sys::Role.permission :delete_private_job_db_companies, module_name: "job_db"
    Sys::Role.permission :release_other_job_db_companies, module_name: "job_db"
    Sys::Role.permission :release_private_job_db_companies, module_name: "job_db"
  end
end
