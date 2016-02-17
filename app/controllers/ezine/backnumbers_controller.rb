class Ezine::BacknumbersController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter

  model Ezine::Page

  append_view_path "app/views/cms/pages"
  navi_view "ezine/main/navi"

  private
    def fix_params
      { cur_site: @cur_site, cur_node: @cur_node }
    end

  public
    def index
      raise "403" unless @cur_node.allowed?(:read, @cur_user, site: @cur_site)

      @items = Ezine::Page.site(@cur_site).node(@cur_node.parent).public(@cur_date).
        allow(:read, @cur_user).
        search(params[:s]).
        order_by(updated: -1).
        page(params[:page]).per(50)
    end
end
