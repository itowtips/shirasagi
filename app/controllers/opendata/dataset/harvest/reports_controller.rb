class Opendata::Dataset::Harvest::ReportsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Opendata::Harvest::Report

  navi_view "opendata/main/navi"

  def destroy
    raise "403" unless @item.allowed?(:delete, @cur_user, site: @cur_site, node: @cur_node)
    render_destroy @item.destroy, location: opendata_harvest_path(id: params[:harvest_id])
  end

  def dataset
    @item = Opendata::Harvest::ReportDataset.find(params[:dataset_id])
  end

  def download
    set_item
    csv = @item.to_csv.encode('SJIS', invalid: :replace, undef: :replace)
    send_data csv, filename: "harvest_report_#{Time.zone.now.to_i}.csv"
  end
end
