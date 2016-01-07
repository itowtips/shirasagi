class Member::BlogLayoutsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Member::BlogLayout

  navi_view "member/blogs/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end
end
