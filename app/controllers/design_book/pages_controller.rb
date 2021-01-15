class DesignBook::PagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter

  model DesignBook::Page

  prepend_view_path "app/views/cms/pages"
  navi_view "cms/node/main/navi"

  before_action :set_tree_navi, only: [:index]

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end

  public

  def index
    raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)

    @node_target_options = @model.new.node_target_options

    @items = @model.site(@cur_site).
      node(@cur_node, params.dig(:s, :target)).
      allow(:read, @cur_user).
      search(params[:s]).
      order_by(updated: -1).
      page(params[:page]).per(50)
  end
end
