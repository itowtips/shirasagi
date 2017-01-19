class JobDb::Incident::CategoriesController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter
  helper JobDb::BaseHelper

  model JobDb::Incident::Category

  navi_view "job_db/incident/main/navi"
  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [ @model.model_name.human, job_db_incident_categories_path ]
    end

    def fix_params
      { cur_user: @cur_user }
    end
end
