class Guide::ImportersController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  navi_view "cms/node/main/navi"

  model Guide::Importer

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end

  public

  def index
    @item = Guide::Importer.new fix_params
  end

  def download_procedures
    @item = Guide::Importer.new fix_params
    filename = "procedures_#{Time.zone.now.to_i}.csv"
    encoding = "Shift_JIS"
    send_enum(@item.procedures_enum, type: "text/csv; charset=#{encoding}", filename: filename)
  end

  def download_questions
    @item = Guide::Importer.new fix_params
    filename = "questions_#{Time.zone.now.to_i}.csv"
    encoding = "Shift_JIS"
    send_enum(@item.questions_enum, type: "text/csv; charset=#{encoding}", filename: filename)
  end

  def download_transitions
    @item = Guide::Importer.new fix_params
    filename = "questions_#{Time.zone.now.to_i}.csv"
    encoding = "Shift_JIS"
    send_enum(@item.transitions_enum, type: "text/csv; charset=#{encoding}", filename: filename)
  end
end
