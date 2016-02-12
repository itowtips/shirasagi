class Rss::PubSubHubbubsController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter

  model Rss::Page

  append_view_path "app/views/cms/pages"
  navi_view "rss/main/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

  public
    def subscribe
      unless request.post?
        return
      end

      @item.subscribe
      redirect_to action: :index
    end

    def unsubscribe
      unless request.delete?
        return
      end

      @item.unsubscribe
      redirect_to action: :index
    end
end
