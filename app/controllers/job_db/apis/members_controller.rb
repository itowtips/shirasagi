class JobDb::Apis::MembersController < ApplicationController
  include SS::BaseFilter
  include SS::CrudFilter
  include SS::AjaxFilter

  model JobDb::Member

  def index
    @items = @model.search(params[:s])
  end
end
