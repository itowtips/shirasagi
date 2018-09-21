class Opendata::Dataset::Harvest::ExportersController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  helper Opendata::FormHelper

  model Opendata::Harvest::Exporter

  navi_view "opendata/main/navi"

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end

  def index
    @items = @model.site(@cur_site).node(@cur_node).allow(:read, @cur_user, site: @cur_site)
  end

  def export
    set_item
    return if request.get?

    Opendata::HarvestDatasetsJob.bind(site_id: @cur_site, node_id: @cur_node).perform_later(exporter_id: @item.id)
    flash.now[:notice] = "エクポート処理を開始しました。"
  end
end
