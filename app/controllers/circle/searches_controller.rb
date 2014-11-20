class Circle::SearchesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Circle::Node::Base

  prepend_view_path "app/views/cms/node/nodes"
  navi_view "circle/search/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "circle/node" }
    end
end
