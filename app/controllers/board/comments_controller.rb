class Board::CommentsController < ApplicationController
  include Gws::BaseFilter
  include SS::CrudFilter

  model Board::Post

  def fix_params
    { user: @cur_user }
  end

  def new
    @parent = @model.find(params[:parent_id])
    super
  end

  def edit
    @parent = @model.find(params[:parent_id])
    super
  end

  def create
    @item = @model.new get_params.merge({parent_id: params[:parent_id]})
    @parent = @item.parent
    render_create @item.save, location: { controller: 'board/topics', action: :show, id: @item.topic_id }
  end
end
