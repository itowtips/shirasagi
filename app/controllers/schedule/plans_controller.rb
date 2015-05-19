class Schedule::PlansController < ApplicationController
  include Gws::BaseFilter
  include SS::CrudFilter

  model Schedule::Plan

  def create
    respond_to do |format|
      format.html { super }
      format.json { super }
      format.js do
        @item = @model.new get_params
        if @item.save
          render status: 200
        else
          render status: 403
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.html { super }
      format.json { super }
      format.js do
        if @item.update get_params
          render status: 200
        else
          render status: 403
        end
      end
    end
  end

  private
    def pre_params
      now = Time.zone.now
      min = now.min / 5 * 5
      start_at = Time.new now.year, now.month, now.day, now.hour, min
      {start_at: start_at, end_at: start_at + 5.minutes}
    end
end
