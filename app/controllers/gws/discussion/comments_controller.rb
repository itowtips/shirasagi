class Gws::Discussion::CommentsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Discussion::Post

  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy, :reply]
  before_action :set_parent

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, topic_id: @topic.id, parent_id: @parent.id }
  end

  def set_item
    @item = @model.find(params[:id])
    #@item.attributes = fix_params
  end

  def set_parent
    @topic = Gws::Discussion::Topic.find(params[:topic_id]) rescue nil
    @parent = @item || @topic
  end

  def set_todos
    @todos = Gws::Schedule::Todo.
      site(@cur_site).
      discussion_topic(@topic).
      allow(:read, @cur_user, site: @cur_site).
      active()
  end

  def set_crumbs
    @crumbs << [I18n.t('modules.gws/discussion'), gws_discussion_topics_path]
  end

  public

  def index
    @items = @topic.children.reorder(created: 1).
      #  search(params[:s]).
      page(params[:page]).per(10)

    set_todos
  end

  def create
    @item = @model.new get_params
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)

    location = { action: :index }
    render_create @item.save, location: location
  end

  def reply
    @comment = @model.new get_params
    @comment.name = @parent.name
    raise "403" unless @comment.allowed?(:edit, @cur_user, site: @cur_site)

    location = params[:redirection] ? params[:redirection] : { action: :index }
    render_create @comment.save, location: location, render: { file: :index }
  end
end
