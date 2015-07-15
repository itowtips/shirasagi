class PublicBoard::CommentsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model PublicBoard::Comment

  #append_view_path "app/views/cms/pages"
  #navi_view "article/main/navi"

  navi_view "cms/main/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

  public
    #
end
