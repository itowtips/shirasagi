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
    @topic =  Gws::Discussion::Topic.find(params[:topic_id]) rescue nil
    @parent = @item || @topic
  end

  def set_crumbs
    @crumbs << [I18n.t('modules.gws/discussion'), gws_discussion_topics_path]
  end

  public

  def index
    @items = @topic.children.reorder(created: 1).
      #  search(params[:s]).
      page(params[:page]).per(10)
  end

  def create
    @item = @model.new get_params
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    render_create @item.save, location: { action: :index }, render: { file: :index }
  end

  def reply
    @comment = @model.new get_params
    @comment.name = @parent.name
    dump(@comment.attributes)
    raise "403" unless @comment.allowed?(:edit, @cur_user, site: @cur_site)
    render_create @comment.save, location: { action: :index }, render: { file: :index }
  end
end
