class Gws::Apis::RemindersController < ApplicationController
  include Gws::ApiFilter
  include Gws::CrudFilter

  model Gws::Reminder

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_item
  end

  def permit_fields
    @model.permitted_fields
  end

  def find_item
    attr = get_params
    reminder = @model.where(
      site_id: @cur_site.id,
      user_id: @cur_user.id,
      model: attr[:model],
      item_id: attr[:item_id]
    ).first
  end

  public

  def create
    item = params[:item_model].camelize.constantize.find(params[:item_id])
    cond = {
      site_id: @cur_site.id,
      user_id: @cur_user.id,
      model: item.reference_model,
      item_id: item.id
    }
    reminder = Gws::Reminder.where(cond).first || Gws::Reminder.new(cond)
    reminder.name = item.reference_name

    reminder.date = item.start_at
    reminder.start_at = item.start_at
    reminder.end_at = item.end_at
    reminder.allday = item.allday

    reminder.repeat_plan_id = item.repeat_plan_id

    # destroy old notifications
    reminder.notifications.destroy_all

    # validate conditions
    conditions = params.dig(:item, :in_reminder_conditions)
    conditions = conditions.map do |cond|
      if item.allday == "allday"
        base_at = Time.zone.parse("#{item.start_at.strftime("%Y/%m/%d")} #{cond["base_time"]}")
      else
        base_at = item.start_at
        cond.delete("base_time")
      end

      cond["interval"] = cond["interval"].to_i
      cond["notify_at"] = base_at - (cond["interval"].send(cond["interval_type"]))
      cond
    end
    conditions = conditions.uniq { |cond| cond["notify_at"] }
    conditions = conditions.sort_by { |cond| cond["notify_at"] }

    conditions.each do |cond|
      next if cond["state"] != "enabled"

      notification = reminder.notifications.new
      notification.notify_at = cond["notify_at"]
      notification.state = cond["state"]
      notification.interval = cond["interval"]
      notification.interval_type = cond["interval_type"]
      notification.base_time = cond["base_time"]

      if notification.notify_at < Time.zone.now
        notification.delivered_at = Time.zone.now
      end
    end

    reminder.save!

    reminder.reload
    reminder.destroy if reminder.notifications.blank?

    render json: { reminder_conditions: (reminder.destroyed? ? [] : reminder.notifications), notice: I18n.t("gws.reminder.states.entry") }
  end

  def destroy
    item = find_item

    if item.blank? || item.destroy
      render plain: I18n.t("gws.reminder.states.empty"), layout: false
    else
      render plain: "Error", layout: false
    end
  end

  def notification
    item = find_item
    raise "404" if item.blank?

    notification = item.notifications.first
    notification = item.notifications.new unless notification
    notification.attributes = params.require(:item).permit(:in_notify_before)

    if notification.valid? && item.save
      render plain: I18n.t("gws.reminder.states.entry"), layout: false
    else
      render plain: "Error", layout: false
    end
  end
end
