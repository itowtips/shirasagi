class Riken::Payment::WorkflowSamplesController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Riken::Payment::WorkflowSample

  navi_view 'riken/payment/main/conf_navi'

  #skip_before_action :logged_in?, only: [:api_index]
  skip_before_action :verify_authenticity_token, only: :api_index

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_crumbs
    @crumbs << [t("riken.payment.main"), gws_riken_payment_main_path]
    @crumbs << [t("riken.payment.workflow_sample"), url_for(action: :index)]
  end

  public

  def api_index
    @items = @model.site(@cur_site).to_a
    render json: @items.map(&:api_attributes).to_json, content_type: json_content_type
  end
end
