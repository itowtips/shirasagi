class JobDb::Company::Area::AreasController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Company::Area

  navi_view "job_db/company/main/navi"
  menu_view "sys/crud/menu"

  before_action :set_cur_area
  before_action :set_crumbs
  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy]

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_company_areas_path]
      @crumbs << [@cur_area.name, job_db_company_area_areas_path]
    end

    def set_cur_area
      @cur_area = @model.find(params[:area_id])
    end

    def fix_params
      { parent: @cur_area, depth: @cur_area.depth + 1 }
    end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user)
      @items = @cur_area.children.allow(:read, @cur_user).
        search(params[:s]).
        page(params[:page]).per(50)
    end

    #def destroy
    #  raise "403" unless @item.allowed?(:delete, @cur_user)
    #  render_destroy @item.disable
    #end
end
