class CompanyList::SearchesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter
  helper JobDb::ListHelper

  model JobDb::Company::Profile

  # append_view_path "app/views/cms/pages"
  navi_view "company_list/main/navi"

  before_action :set_ss_user

  private
    def set_ss_user
      @cur_ss_user = SS::User.find(@cur_user.id)
    end

    def set_items
      @items = @model.site(@cur_site)
        .allow(:read, @cur_ss_user)
        .order_by(updated: -1)
    end

    def set_item
      super
    end

  public
    def index
      set_items
      @items = @items.search(params[:s]).page(params[:page]).per(50)
    end

    def show
      raise "403" unless @item.allowed?(:read, @cur_ss_user)
      render
    end
end
