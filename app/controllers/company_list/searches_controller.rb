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
      raise "403" unless @cur_user.cms_role_permission(@cur_site, :company_list, :companies, :read) > 0
      set_items
      @items = @items.search(params[:s]).page(params[:page]).per(50)
    end

    def show
      raise "403" unless @cur_user.cms_role_permission(@cur_site, :company_list, :companies, :read) > 0
      render
    end
end
