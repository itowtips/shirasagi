class Opendata::Dataset::Harvest::Exporter::OwnerOrgSettingsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  helper Opendata::FormHelper

  model Opendata::Harvest::Exporter::OwnerOrgSetting

  before_action :set_exporter
  before_action :set_crumbs

  navi_view "opendata/main/navi"

  private

  def set_crumbs
    @crumbs << ["ハーベスト", opendata_harvest_exporters_path]
  end

  public

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, exporter: @exporter }
  end

  def set_exporter
    @exporter = Opendata::Harvest::Exporter.site(@cur_site).node(@cur_node).find(params[:exporter_id])
  end

  def index
    @items = @exporter.owner_org_settings
  end
end
