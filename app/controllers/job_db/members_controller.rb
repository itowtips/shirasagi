class JobDb::MembersController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Member

  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_members_path]
    end
end
