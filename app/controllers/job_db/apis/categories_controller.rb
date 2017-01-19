class JobDb::Apis::CategoriesController < ApplicationController
  include SS::BaseFilter
  include SS::CrudFilter
  include SS::AjaxFilter

  before_action :set_model

  private
    def set_model
      @model = params[:model].constantize
    end

  public
    def index
      @items = @model.search(params[:s])
    end
end
