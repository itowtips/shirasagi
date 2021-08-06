class Cms::Agents::Parts::MonthlyNavController < ApplicationController
  include Cms::PartFilter::View

  before_action :set_condition_hash

  def index
    @months = []
    @cur_part.becomes_with_route.periods.times do |i|
      @months.push [ previous_month_beginning(i), contents_size(i)]
    end
  end

  private

  def set_condition_hash
    if @cur_part.parent.present?
      if @cur_part.parent.route == "cms/archive"
        @condition_hash = @cur_part.parent.try(:parent).try(:becomes_with_route).try(:condition_hash)
      else
        @condition_hash = @cur_part.parent.becomes_with_route.try(:condition_hash)
      end
    end
  end

  def previous_month_beginning(num)
    (Time.zone.today - num.month).beginning_of_month
  end

  def previous_month_end(num)
    (Time.zone.today - num.month).end_of_month.end_of_day
  end

  def contents_size(num)
    Cms::Page.site(@cur_site).and_public(@cur_date).
      where(@condition_hash).
      where(:released.gte => previous_month_beginning(num), :released.lte => previous_month_end(num))
      .count
  end
end
