class Gws::Apis::TempFilesController < ApplicationController
  include Sns::UserFilter
  include Sns::CrudFilter
  include SS::FileFilter
  include SS::AjaxFileFilter

  model Gws::TempFile

  before_action :set_current_site

  layout "ss/ajax"

  private

  def fix_params
    { cur_user: @cur_user }
  end

  def set_current_site
    @ss_mode = :gws
    @cur_site = SS.current_site = Gws::Group.find params[:site]
  end
end
