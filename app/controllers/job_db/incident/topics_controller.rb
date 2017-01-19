class JobDb::Incident::TopicsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter
  helper JobDb::BaseHelper

  model JobDb::Incident::Topic

  navi_view "job_db/incident/main/navi"
  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [ @model.model_name.human, job_db_incident_topics_path ]
    end

    def fix_params
      { cur_user: @cur_user }
    end
end
