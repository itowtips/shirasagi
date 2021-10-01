class Pippi::TipsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Pippi::Tips

  navi_view "pippi/tips/navi"

  before_action :set_year_month_day
  before_action :set_tips_years
  before_action :set_crumbs
  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy]

  private

  def set_crumbs
    super
    @crumbs << ["#{@year}#{I18n.t("datetime.prompts.year")}", { action: :index, year: @year }]
  end

  def set_year_month_day
    if params[:ymd].blank?
      redirect_to({ action: :index, ymd: Time.zone.today.strftime("%Y%m%d") })
      return
    end

    raise '404' if params[:ymd].length != 8
    @year = params[:ymd][0..3].to_i
    @month = params[:ymd][4..5].to_i
    @day = params[:ymd][6..7].to_i
    @cur_date = Time.zone.parse("#{@year}/#{@month}/#{@day}").to_date

    @start_of_month = @cur_date.change(day: 1)
    @end_of_month = @cur_date.end_of_month
  end

  def set_tips_years
    @years = []
    year = Time.zone.today.year
    (year + 1).downto(year - 10) do |y|
      if y >= year || Pippi::Tips.site(@cur_site).node(@cur_node).where(year: y).present?
        @years << y
      end
    end
  end

  def set_items
    @items = Pippi::Tips.site(@cur_site).node(@cur_node).
      where(year: @year, month: @month).
      allow(:read, @cur_user, site: @cur_site).to_a
    @items = @items.map { |item| [item.date.to_date, item] }.to_h
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node, date: @cur_date }
  end

  public

  def index
    set_items
  end

  def download_all
    raise "403" if !@model.allowed?(:read, @cur_user, site: @cur_site)
    return if request.get?

    csv_params = params.require(:item).permit(:encoding)
    exporter = Pippi::Tips::Exporter.new(@cur_site, @cur_node, @year, csv_params)

    filename = @model.to_s.tableize.gsub(/\//, "_")
    filename = "#{filename}_#{@year}.csv"
    content_type = "text/csv; charset=#{csv_params[:encoding]}"

    response.status = 200
    send_enum exporter.enum_csv, type: content_type, filename: filename
  end

  def import
    raise "403" if !@model.allowed?(:edit, @cur_user, site: @cur_site)
    return if request.get?

    @item = Pippi::Tips::Importer.new(@cur_site, @cur_node, @cur_user, @year)
    begin
      file = params[:item].try(:[], :file)
      if file.nil? || ::File.extname(file.original_filename) != ".csv"
        raise I18n.t("errors.messages.invalid_csv")
      end
      if !Pippi::Tips::Importer.valid_csv?(file)
        raise I18n.t("errors.messages.malformed_csv")
      end
    rescue => e
      @item.errors.add :base, e.to_s
    end

    if @item.errors.present?
      render
      return
    end

    render_create @item.import(file), location: { action: :index }, render: :import
  end
end
