class Tourism::Apis::PagesController < ApplicationController
  include Cms::ApiFilter

  model Tourism::Page

  before_action :set_single

  private

  def set_single
    @single = params[:single].present?
    @multi = !@single
  end

  public

  def index
    @single = params[:single].present?
    @multi = !@single

    @items = @model.site(@cur_site).
      search(params[:s]).
      order_by(_id: -1).
      page(params[:page]).per(50)
  end
end
