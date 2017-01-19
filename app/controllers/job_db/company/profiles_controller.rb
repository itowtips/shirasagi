class JobDb::Company::ProfilesController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Company::Profile

  navi_view "job_db/company/main/navi"
  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_company_profiles_path]
    end

    def pre_params
      { state: 'closed' }
    end
end
