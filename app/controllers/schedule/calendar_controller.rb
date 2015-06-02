class Schedule::CalendarController < ApplicationController
  include Gws::BaseFilter

  def index
    @plans = Schedule::Plan.all
  end
end
