module Gws::Addon
  module Reminder
    extend ActiveSupport::Concern
    extend SS::Addon

    attr_accessor :reminder_url, :in_reminder_state, :in_reminder_date
    attr_accessor :in_reminder_conditions

    included do
      permit_params :reminder_url, :in_reminder_state, :in_reminder_date
      permit_params in_reminder_conditions: [:user_id, :state, :interval, :interval_type, :base_time]

      validate :validate_in_reminder_conditions
      after_save :save_reminders, if: -> { in_reminder_conditions }
      after_save :update_reminders, if: -> { in_reminder_conditions.nil? }
      #after_destroy :destroy_reminders
    end

    def reminders
      @reminders ||= Gws::Reminder.where(model: reference_model, item_id: id, site_id: site_id)
    end

    #def destroy_reminders
    #  Gws::Reminder.where(model: reference_model, item_id: id, site_id: site_id).user(@cur_user).destroy
    #end

    def reminder_conditions(user)
      return [] if new_record?
      cond = {
        site_id: site_id,
        user_id: user.id,
        model: reference_model,
        item_id: id
      }
      item = Gws::Reminder.where(cond).first
      item ? item.notifications : []
    end

    def reminder(user = @cur_user)
      @reminder ||= reminders.user(user).first
    end

    def in_reminder_state
      return @in_reminder_state if @in_reminder_state
      return 'enabled' if new_record?
      reminder ? 'enabled' : 'disabled'
    end

    def in_reminder_date
      if @in_reminder_date
        date = Time.zone.parse(@in_reminder_date) rescue nil
      end
      date ||= reminder ? reminder.date : (reminder_date || Time.zone.now + 7.days)
      date
    end

    def reminder_date
      try(:start_at)
    end

    def reminder_url
      name = reference_model.tr('/', '_') + '_path'
      [name, id: id]
    end

    def reminder_user_ids
      [@cur_user.try(:id), user_id].compact
    end

    def reminder_state_options
      [
        [ "通知しない", "disabled" ],
        [ "通知する", "enabled" ],
      ]
    end

    def reminder_interval_type_options
      [
        [ "分前", "minutes" ],
        [ "時間前", "hours" ],
        [ "日前", "days" ],
        [ "週前", "weeks" ],
      ]
    end

    def reminder_base_time_options
      [
          [ "午前 8:00", "8:00" ],
          [ "午前 8:30", "8:30" ],
          [ "午前 9:00", "9:00" ],
          [ "午前 9:30", "9:30" ],
          [ "午前 10:00", "10:00" ],
          [ "午前 10:30", "10:30" ],
          [ "午前 11:00", "11:00" ],
          [ "午前 11:30", "11:30" ],
          [ "午前 12:00", "12:00" ],
      ]
    end

    def validate_in_reminder_conditions
      return if in_reminder_conditions.blank?
      self.in_reminder_conditions = in_reminder_conditions.map do |cond|
        if allday == "allday"
          base_at = Time.zone.parse("#{start_at.strftime("%Y/%m/%d")} #{cond["base_time"]}")
        else
          base_at = start_at
          cond.delete("base_time")
        end

        cond["notify_at"] = base_at - (cond["interval"].to_i.send(cond["interval_type"]))
        cond
      end
      self.in_reminder_conditions = in_reminder_conditions.uniq { |cond| cond["notify_at"] }
      self.in_reminder_conditions = in_reminder_conditions.sort_by { |cond| cond["notify_at"] }
    end

    def remove_repeat_reminder(base_plan)
      cond = {
        site_id: site_id,
        user_id: base_plan.cur_user.id,
        model: reference_model,
        item_id: id
      }
      Gws::Reminder.where(cond).destroy
    end

    def set_repeat_reminder_conditions(base_plan)
      self.cur_user = base_plan.cur_user
      self.in_reminder_conditions = base_plan.in_reminder_conditions
    end

    private

    def save_reminders
      #return if reminder_url.blank?
      return if @db_changes.blank?
      return if @cur_user.blank?

      cond = {
        site_id: site_id,
        user_id: @cur_user.id,
        model: reference_model,
        item_id: id
      }
      reminder = Gws::Reminder.where(cond).first || Gws::Reminder.new(cond)
      reminder.name = reference_name
      reminder.date = start_at
      reminder.repeat_plan_id = repeat_plan_id

      # destroy old notifications
      reminder.notifications.destroy_all
      in_reminder_conditions.each do |cond|
        next if cond["state"] != "enabled"

        notification = reminder.notifications.new
        notification.notify_at = cond["notify_at"]
        notification.state = cond["state"]
        notification.interval = cond["interval"]
        notification.interval_type = cond["interval_type"]
        notification.base_time = cond["base_time"]
      end

      reminder.save!
    end

    def update_reminders
      #return if reminder_url.blank?
      return if @db_changes.blank?
      return if @cur_user.blank?
      cond = {
          site_id: site_id,
          user_id: @cur_user.id,
          model: reference_model,
          item_id: id
      }
      reminder = Gws::Reminder.where(cond).first
      return unless reminder

      reminder.name = reference_name
      reminder.date = start_at
      reminder.repeat_plan_id = repeat_plan_id

      reminder.notifications.each do |notification|
        if allday == "allday"
          base_at = Time.zone.parse("#{start_at.strftime("%Y/%m/%d")} #{notification.base_time}")
        else
          base_at = start_at
        end

        notification.notify_at = base_at - (notification.interval.send(notification.interval_type))
      end

      reminder.save!
    end

=begin
    def save_reminders
      return if reminder_url.blank?
      return if @db_changes.blank?

      new_record = @db_changes.key?('_id')
      removed_user_ids = reminders.map(&:user_id) - reminder_user_ids
      removed_user_ids << @cur_user.id if @cur_user && @in_reminder_state == 'disabled'

      base_cond = {
        site_id: site_id,
        model: reference_model,
        item_id: id
      }
      self_updated_fields = @db_changes.keys.reject { |s| s =~ /_hash$/ }

      ## save reminders
      reminder_user_ids.each do |user_id|
        next if removed_user_ids.include?(user_id)

        cond = base_cond.merge(user_id: user_id)
        item = Gws::Reminder.where(cond).first || Gws::Reminder.new(cond)
        item.name = reference_name
        item.date = @in_reminder_date || reminder_date
        item.updated_fields = self_updated_fields unless new_record
        if @cur_user
          item.updated_user_id = @cur_user.id
          item.updated_user_uid = @cur_user.uid
          item.updated_user_name = @cur_user.name
          item.updated_date = updated
        end
        item.save if item.changed?
      end

      ## delete reminders
      cond = base_cond.merge(:user_id.in => removed_user_ids)
      Gws::Reminder.where(cond).destroy_all
    end
=end
  end
end
