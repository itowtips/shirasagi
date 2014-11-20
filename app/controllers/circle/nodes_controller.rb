class Circle::NodesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Circle::Node::Base

  prepend_view_path "app/views/cms/node/nodes"
  navi_view "circle/node/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "circle/page" }
    end

  public
    def index
      redirect_to circle_pages_path
      return
    end
end
