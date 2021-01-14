class Cms::Apis::TempFilesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter
  include SS::FileFilter
  include SS::AjaxFileFilter

  model Cms::TempFile

  def index
    @select_ids = params[:select_ids].presence

    @items = @model.site(@cur_site).
      where(:node_id.exists => false).
      allow(:read, @cur_user)

    if @select_ids.present?
      @items = @items.in(id: @select_ids).order_by(filename: 1)
    else
      @items = @items.order_by(filename: 1).
        page(params[:page]).per(20)
    end
  end

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end
end
