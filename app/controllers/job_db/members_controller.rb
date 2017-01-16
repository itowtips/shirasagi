class JobDb::MembersController < ApplicationController
  include Sys::BaseFilter
  include Sys::CrudFilter

  model JobDb::Member

  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [@model.model_name.human, job_db_members_path]
    end

  public
    def index
      raise "403" unless @model.allowed?(:edit, @cur_user)
      @items = @model.allow(:edit, @cur_user).
        and_state(params.dig(:s, :state)).
        search(params[:s]).
        order_by(_id: -1).
        page(params[:page]).per(50)
    end

    def destroy
      raise "403" unless @item.allowed?(:delete, @cur_user)
      render_destroy @item.disable
    end
end
