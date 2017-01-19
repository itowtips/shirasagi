class JobDb::Incident::TopicsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter

  model JobDb::Incident::Topic

  menu_view "sys/crud/menu"

  private
    def set_crumbs
      @crumbs << [ @model.model_name.human, job_db_incident_topics_path ]
    end

    def fix_params
      { cur_user: @cur_user }
    end

    # def pre_params
    #   p = super
    #   if @category.present?
    #     p[:category_ids] = [ @category.id ]
    #   end
    #   p
    # end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user)
      @items = @model.allow(:read, @cur_user).
        search(params[:s]).
        order_by(_id: -1).
        page(params[:page]).per(50)
    end
end
