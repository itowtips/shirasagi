class Gws::Affair::Leave::Apis::SpecialLeavesController < ApplicationController
  include Gws::ApiFilter

  model Gws::Affair::SpecialLeave

  def index
    @items = @model.site(@cur_site).
      allow(:read, @cur_user, site: @cur_site).
      search(params[:s]).
      order_by(order: 1).
      page(params[:page]).per(50)
  end
end
