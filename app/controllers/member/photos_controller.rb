class Member::PhotosController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter
  include Member::Photo::PageFilter

  model Member::Photo

  navi_view "cms/node/main/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node, layout: @layout }
    end

    def set_item
      super
      @categories = Member::Node::PhotoCategory.site(@cur_site).and_public
      @locations  = Member::Node::PhotoLocation.site(@cur_site).and_public
      @layout     = @cur_node.page_layout rescue nil
    end

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)

      @items = @model.site(@cur_site).
        allow(:read, @cur_user, site: @cur_site).
        order_by(released: -1).
        page(params[:page]).per(50)
    end
end
