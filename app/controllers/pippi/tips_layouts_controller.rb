class Pippi::TipsLayoutsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Pippi::TipsLayout

  navi_view "pippi/tips/navi"

  before_action :set_year_month_day
  before_action :set_tips_years

  private

  def set_year_month_day
    @cur_date = Time.zone.today
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

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end
end
