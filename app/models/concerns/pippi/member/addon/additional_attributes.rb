module Pippi::Member::Addon
  module AdditionalAttributes
    extend SS::Addon
    extend ActiveSupport::Concern

    CHILD_MAX_SIZE = 5

    included do
      field :subscribe_line_message, type: String, default: "active"
      field :residence_areas, type: Array, default: []

      validates :subscribe_line_message, inclusion: { in: %w(active expired) }
      validate :validate_residence_areas
      permit_params :subscribe_line_message
      permit_params residence_areas: []

      1.upto(CHILD_MAX_SIZE) do |i|
        field :"child#{i}_birthday", type: Date
        attr_accessor :"in_child#{i}_birth"

        permit_params :"in_child#{i}_birth" => [:era, :year, :month, :day]
        validate :"set_child#{i}_birthday"
      end
    end

    def subscribe_line_message_options
      %w(active expired).map { |m| [ I18n.t("pippi.options.subscribe_line_message.#{m}"), m ] }.to_a
    end

    def residence_areas_options
      I18n.t("pippi.options.residence_areas").map { |k, v| [v, k] }
    end

    def validate_residence_areas
      self.residence_areas = residence_areas.select(&:present?)
      return if residence_areas.blank?

      if (residence_areas - I18n.t("pippi.options.residence_areas").keys.map(&:to_s)).present?
        errors.add :residence_areas, :inclusion
      end
    end

    1.upto(CHILD_MAX_SIZE) do |i|
      accessor_key = :"in_child#{i}_birth"
      field_key = :"child#{i}_birthday"

      define_method("parse_in_child#{i}_birth") do
        in_child_birth = send(accessor_key)
        child_birthday = send(field_key)

        if in_child_birth
          era   = in_child_birth["era"]
          year  = in_child_birth["year"]
          month = in_child_birth["month"]
          day   = in_child_birth["day"]
        else
          era   = child_birthday ? "seireki" : nil
          year  = child_birthday.try(:year)
          month = child_birthday.try(:month)
          day   = child_birthday.try(:day)
        end

        [era, year, month, day]
      end

      define_method("set_child#{i}_birthday") do
        in_child_birth = send(accessor_key).presence || {}
        era = in_child_birth[:era]
        year = in_child_birth[:year]
        month = in_child_birth[:month]
        day = in_child_birth[:day]

        if era.blank? && year.blank? && month.blank? && day.blank?
          send("#{field_key}=", nil)
          return
        elsif era.blank? || year.blank? || month.blank? || day.blank?
          errors.add field_key, :invalid
          return
        end

        year = year.to_i
        month = month.to_i
        day = day.to_i

        begin
          wareki = I18n.t("ss.wareki")[era.to_sym]
          min = Date.parse(wareki[:min])
          date = Date.new(min.year + year - 1, month, day)
          send("#{field_key}=", date)
        rescue
          errors.add field_key, :invalid
        end
      end
    end
  end
end
