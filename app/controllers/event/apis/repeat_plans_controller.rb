class Event::Apis::RepeatPlansController < ApplicationController
  include Cms::ApiFilter

  public
    def index
      #
    end

    def create
      @repeat_type = params[:repeat_type]
      @repeat_start = params[:repeat_start]
      @repeat_end = params[:repeat_end]
      @interval = params[:interval]
      @wdays = params[:wdays]
      @interval = 1

      @repeat_start = Date.parse(@repeat_start)
      @repeat_end = Date.parse(@repeat_end)

      dates = []
      range = []
      plan_dates.each do |d|
        if range.present? && range.last.tomorrow != d
          dates << range
          range = []
        end
        range << d
      end
      dates << range if range.present?
      @dates = dates.map { |range| [range.first, range.last] }
    end

  private
    def plan_dates
      case @repeat_type
      when 'daily'
        daily_dates
      when 'weekly'
        weekly_dates
      when 'monthly'
        monthly_dates
      else
        []
      end
    end

    def daily_dates
      @repeat_start.step(@repeat_end, @interval).to_a
    end

    def weekly_dates
      []
    end

    def monthly_dates
      []
    end
end
