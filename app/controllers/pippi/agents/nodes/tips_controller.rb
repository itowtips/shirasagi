class Pippi::Agents::Nodes::TipsController < ApplicationController
  include Cms::NodeFilter::View
  helper SS::JbuilderHelper

  before_action :set_year_month_day
  before_action :set_years

  def set_year_month_day
    if params[:ymd].blank?
      @cur_date = Time.zone.today
      return
    end

    raise "404" if params[:ymd].length != 8
    @year = params[:ymd][0..3].to_i
    @month = params[:ymd][4..5].to_i
    @day = params[:ymd][6..7].to_i
    @cur_date = Time.zone.parse("#{@year}/#{@month}/#{@day}").to_date
  end

  def set_years
    @years = []
    year = Time.zone.today.year
    (year + 1).downto(year - 10) do |y|
      if y >= year || Pippi::Tips.site(@cur_site).node(@cur_node).where(year: y).present?
        @years << y
      end
    end
    raise "404" if !@years.include?(@cur_date.year)
  end

  def index
    @item = Pippi::Tips.site(@cur_site).node(@cur_node).where(date: @cur_date).first
    @item ||= begin
      item = Pippi::Tips.new(site: @cur_site, node: @cur_node)
      item.date = @cur_date
      item.send(:set_name)
      item.send(:set_ymd)
      item
    end
  end
end
