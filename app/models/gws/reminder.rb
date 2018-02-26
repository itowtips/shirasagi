class Gws::Reminder
  include SS::Document
  include Gws::Reference::User
  include Gws::Reference::Site
  include SS::UserPermission

  seqid :id

  field :read_at, type: DateTime
  field :updated_fields, type: Array
  field :updated_user_id, type: Integer
  field :updated_user_uid, type: String
  field :updated_user_name, type: String
  field :updated_date, type: DateTime
  embeds_many :notifications, class_name: "Gws::Reminder::Notification"

  field :name, type: String
  field :model, type: String
  field :date, type: DateTime
  field :start_at, type: DateTime
  field :end_at, type: DateTime
  field :allday, type: String
  field :item_id, type: String
  belongs_to :repeat_plan, class_name: "Gws::Schedule::RepeatPlan"

  permit_params :name, :model, :date, :item_id

  validates :name, presence: true
  validates :model, presence: true
  validates :date, datetime: true
  validates :item_id, presence: true

  default_scope -> {
    order_by date: 1
  }
  scope :search, ->(params) {
    criteria = where({})
    return criteria if params.blank?

    criteria = criteria.keyword_in params[:keyword], :name if params[:keyword].present?
    criteria
  }
  scope :notification_activated, -> {
    where(
      "notifications.notify_at" => { "$exists" => true, "$ne" => Time.zone.at(0) },
      "notifications.delivered_at" => Time.zone.at(0))
  }
  scope :notify_between, ->(from, to) {
    notification_activated.where("notifications.notify_at" => { "$gte" => from, "$lt" => to })
  }

  def item
    @item ||= model.camelize.constantize.where(id: item_id).first
  end

  def similar_name_items
    model.camelize.constantize.where(name: /#{Regexp.escape(name)}/)
  end

  def similar_repeat_items
    model.camelize.constantize.where(repeat_plan_id: repeat_plan_id)
  end

  def url_lazy
    url, options = item.reminder_url
    -> { send(url, options) rescue nil }
  rescue
    -> { nil }
  end

  def updated?
    updated_fields.present?
  end

  def unread?
    read_at.to_i < updated.to_i
  end

  def updated_field_names
    return [] if updated_fields.blank?
    updated_fields.map { |m| item.try(:t, m) }.compact.uniq
  end

  def notification_options
    %w(-1 10 30 60).map do |v|
      [ I18n.t("gws.options.reminder/notification.#{v}"), v ]
    end
  end
end
