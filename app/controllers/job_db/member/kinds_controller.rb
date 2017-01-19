class JobDb::Member::KindsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Member::Kind

  navi_view "job_db/members/navi"
  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_member_kinds_path]
    end
end
