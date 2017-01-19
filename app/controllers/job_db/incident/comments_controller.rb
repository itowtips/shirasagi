class JobDb::Incident::CommentsController < ApplicationController
  include JobDb::BaseFilter
  include JobDb::CrudFilter
  helper JobDb::BaseHelper

  model JobDb::Incident::Comment

  navi_view "job_db/incident/main/navi"
  menu_view "sys/crud/menu"

  before_action :set_topic
  before_action :set_parent

  private
    def set_topic
      @topic ||= JobDb::Incident::Topic.find(params[:topic_id])
    end

    def set_parent
      # parent is optional
      if params[:parent_id].present?
        @parent ||= JobDb::Incident::Base.find(params[:parent_id])
      end
    end

    def set_crumbs
      set_topic
      @crumbs << [ @model.model_name.human, job_db_incident_topics_path ]
      @crumbs << [ @topic.name, job_db_incident_topic_path(id: @topic) ]
    end

    def fix_params
      set_topic
      set_parent
      { cur_user: @cur_user, cur_topic: @topic, cur_parent: @parent }
    end

  public
    def index
      redirect_to job_db_incident_topic_path(id: @topic)
    end

    def show
      redirect_to "#{job_db_incident_topic_path(id: @topic)}##{@item.id}"
    end

    def new
      raise "403" unless @topic.allowed?(:edit, @cur_user)
      @item = @model.new pre_params.merge(fix_params)
    end

    def create
      raise "403" unless @topic.allowed?(:edit, @cur_user)
      @item = @model.new get_params
      @item.parent_id ||= @topic.id
      render_create @item.save
    end

    def edit
      raise "403" unless @topic.allowed?(:edit, @cur_user)
      render
    end

    def update
      raise "403" unless @topic.allowed?(:edit, @cur_user)
      @item.attributes = get_params
      render_update @item.update
    end

    def delete
      raise "403" unless @topic.allowed?(:delete, @cur_user)
      render
    end

    def destroy
      raise "403" unless @topic.allowed?(:delete, @cur_user)
      render_destroy @item.destroy
    end
end
