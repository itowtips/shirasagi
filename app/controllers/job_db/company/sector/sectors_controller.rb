class JobDb::Company::Sector::SectorsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Company::Sector

  navi_view "job_db/company/main/navi"
  menu_view "sys/crud/menu"

  before_action :set_cur_sector
  before_action :set_crumbs
  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy]

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_company_sectors_path]
      @crumbs << [@cur_sector.name, job_db_company_sector_sectors_path]
    end

    def set_cur_sector
      @cur_sector = @model.find(params[:sector_id])
    end

    def fix_params
      { parent: @cur_sector, depth: @cur_sector.depth + 1 }
    end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user)
      @items = @cur_sector.children.allow(:read, @cur_user).
        search(params[:s]).
        page(params[:page]).per(50)
    end

    #def destroy
    #  raise "403" unless @item.allowed?(:delete, @cur_user)
    #  render_destroy @item.disable
    #end
end
