class Opendata::Dataset::CkanExportersController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  helper Opendata::FormHelper

  model Opendata::CkanExporter

  navi_view "opendata/main/navi"

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end

  def index
    @items = @model.site(@cur_site).node(@cur_node).allow(:read, @cur_user, site: @cur_site)
  end

  #def import
  #  set_item
  #  return if request.get?
  #
  #  Opendata::HarvestDatasetsJob.bind(site_id: @cur_site, node_id: @cur_node).perform_later(@item.id)
  #  flash.now[:notice] = "インポート処理を開始しました。"
  #end
end
