class Board::TopicsController < ApplicationController
  include Gws::BaseFilter
  include SS::CrudFilter

  model Board::Post

  def fix_params
    { user: @cur_user }
  end

  def index
    @items = Board::Post.topic.order(descendants_updated: -1)
  end

  def show
    render file: "show_#{@item.mode}"
  end
end
