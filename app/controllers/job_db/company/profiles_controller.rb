class JobDb::Company::ProfilesController < ApplicationController
  include Sys::BaseFilter
  include Sys::CrudFilter

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

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user)
      @items = @model.allow(:read, @cur_user).
        search(params[:s]).
        order_by(_id: -1).
        page(params[:page]).per(50)
    end

    def destroy
      raise "403" unless @item.allowed?(:delete, @cur_user)
      render_destroy @item.disable
    end
end
