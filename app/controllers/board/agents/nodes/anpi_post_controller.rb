class Board::Agents::Nodes::AnpiPostController < ApplicationController
  include Cms::NodeFilter::View
  include Cms::PublicFilter::Crud

  model Board::AnpiPost

  private
    def fix_params
      { cur_site: @cur_site, cur_node: @cur_node }
    end

  public
    def index
      safe_params = params.permit(:keyword)
      return if safe_params.blank?
      @items = @model.site(@cur_site).
        search(safe_params).
        and_public.
        page(params[:page]).
        per(@cur_node.limit)

      render_with_pagination(@items)
    end
end
