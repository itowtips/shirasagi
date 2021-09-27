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

    def calculate_age(today, birthday)
      # year
      d1 = format("%04d%02d%02d", today.year, today.month, today.day).to_i
      d2 = format("%04d%02d%02d", birthday.year, birthday.month, birthday.day).to_i
      d3 = (d1 - d2)
      d3 = format("%08d", (d3 > 0) ? d3 : 0)
      y = d3[0..3].to_i

      # month
      if today > birthday
        m = today.day >= birthday.day ? today.month : today.advance(months: -1).month
        m = (m >= birthday.month) ? m - birthday.month : (12 - birthday.month) + m
      else
        m = 0
      end
      [y, m]
    end

    def child_ages
      ages = []
      1.upto(CHILD_MAX_SIZE) do |i|
        ages << send("child#{i}_age")
      end
      ages.compact
    end

    def child_ages_labels
      (1..Cms::Member::CHILD_MAX_SIZE).map { |i| send("child#{i}_age_label") }.compact
    end

    def residence_areas_labels
      residence_areas.map { |k| I18n.t("pippi.options.residence_areas.#{k}") }
    end

    1.upto(CHILD_MAX_SIZE) do |i|
      accessor_key = :"in_child#{i}_birth"
      field_key = :"child#{i}_birthday"

      define_method("child#{i}_age") do
        child_birthday = send(field_key)
        return if child_birthday.blank?
        calculate_age(Time.zone.today, child_birthday)
      end

      define_method("child#{i}_age_label") do
        birthday = send("child#{i}_birthday")
        y, m = send("child#{i}_age")
        birthday ? "#{I18n.l(birthday.to_date, format: :long)}（#{y}歳#{m}ヶ月）" : nil
      end

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

    module ClassMethods
      def encode_sjis(str)
        str.encode("SJIS", invalid: :replace, undef: :replace)
      end

      def line_members_enum
        members = criteria.to_a
        Enumerator.new do |y|
          headers = %w(id name oauth_id child_ages residence_areas).map { |v| self.t(v) }
          y << encode_sjis(headers.to_csv)
          members.each do |item|
            row = []
            row << item.id
            row << item.name
            row << item.oauth_id
            row << item.child_ages_labels.join("\n")
            row << item.residence_areas_labels.join("\n")
            y << encode_sjis(row.to_csv)
          end
        end
      end
    end
  end
end
