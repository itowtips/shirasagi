class JobDb::Company::PrefectureCertificationsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Company::PrefectureCertification

  navi_view "job_db/company/main/navi"
  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_company_areas_path]
    end

    def fix_params
      { depth: 1 }
    end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user)
      @items = @model.allow(:read, @cur_user).
        where(depth: 1).
        search(params[:s]).
        page(params[:page]).per(50)
    end

    def destroy
      raise "403" unless @item.allowed?(:delete, @cur_user)
      render_destroy @item.disable
    end
end
