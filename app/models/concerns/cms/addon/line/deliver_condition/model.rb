module Cms::Addon
  module Line::DeliverCondition::Model
    extend ActiveSupport::Concern

    CHILD_CONDITION_MAX_SIZE = 5

    included do
      1.upto(CHILD_CONDITION_MAX_SIZE) do |i|
        field :"lower_year#{i}", type: Integer
        field :"upper_year#{i}", type: Integer
        permit_params :"lower_year#{i}", :"upper_year#{i}"
      end

      field :residence_areas, type: Array, default: []
      permit_params residence_areas: []
    end

    def residence_areas_options
      I18n.t("pippi.options.residence_areas").map { |k, v| [v, k] }
    end

    def condition_ages
      years = []
      1.upto(CHILD_CONDITION_MAX_SIZE) do |i|
        lower_year = send("lower_year#{i}")
        upper_year = send("upper_year#{i}")
        years += (lower_year..upper_year).to_a if lower_year && upper_year
      end
      years.uniq.sort
    end

    def condition_label
      h = []
      h << (1..CHILD_CONDITION_MAX_SIZE).map do |i|
        lower_year = send("lower_year#{i}")
        upper_year = send("upper_year#{i}")
        next unless lower_year && upper_year
        (lower_year == upper_year) ? "#{lower_year}歳" : "#{lower_year}歳〜#{upper_year}歳"
      end.compact.join(", ")
      h << residence_areas.map { |area| I18n.t("pippi.options.residence_areas.#{area}") }.join(", ")
      h.select(&:present?).join("\n")
    end

    def extract_multicast_members
      criteria = Cms::Member.site(site)
      criteria = criteria.where(:oauth_id.exists => true, oauth_type: "line")
      criteria.where(subscribe_line_message: "active")
    end

    def extract_conditional_members
      criteria = extract_multicast_members

      if residence_areas.present?
        criteria = criteria.in(residence_areas: residence_areas)
      end

      if condition_ages.present?
        members = criteria.to_a.select do |member|
          (condition_ages & member.child_ages).present?
        end
        criteria = Cms::Member.in(id: members.pluck(:id))
      end

      criteria
    end

    def empty_members
      Cms::Member.none
    end

    private

    def validate_residence_areas
      self.residence_areas = residence_areas.select(&:present?)
      return if residence_areas.blank?

      if (residence_areas - I18n.t("pippi.options.residence_areas").keys.map(&:to_s)).present?
        errors.add :residence_areas, :inclusion
      end
    end

    1.upto(CHILD_CONDITION_MAX_SIZE) do |i|
      define_method("validate_year#{i}") do
        lower_year = send("lower_year#{i}")
        upper_year = send("upper_year#{i}")

        if lower_year && upper_year
          if lower_year > upper_year
            errors.add "upper_year#{i}", :greater_than, count: t("lower_year#{i}")
          end
        elsif lower_year
          errors.add "upper_year#{i}", :blank
        elsif upper_year
          errors.add "lower_year#{i}", :blank
        end
      end
    end

    def validate_condition_body
      1.upto(CHILD_CONDITION_MAX_SIZE).each { |i| send("validate_year#{i}") }
      validate_residence_areas
      return if errors.present?

      if condition_ages.blank? && residence_areas.blank?
        errors.add :base, "配信条件を入力してください"
      end
    end
  end
end
