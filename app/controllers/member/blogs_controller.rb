class Member::BlogsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Member::Blog

  navi_view "member/my_blog/navi"

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)

      @items = @model.site(@cur_site).
        allow(:read, @cur_user, site: @cur_site).
        order_by(released: -1).
        page(params[:page]).per(50)
    end

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site }
    end

end
