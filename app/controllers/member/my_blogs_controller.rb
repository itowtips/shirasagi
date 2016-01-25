class Member::MyBlogsController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Member::Node::MyBlog

  navi_view "cms/node/main/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "member/my_blog" }
    end
end
