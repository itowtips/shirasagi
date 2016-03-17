module Member::Addon
  module AdditionalAttributes
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :kana, type: String
      field :tel, type: String
      field :addr, type: String
      field :sex, type: String
      field :birthday, type: Date
      attr_accessor :in_birth
      permit_params :kana, :tel, :addr, :sex, :birthday
      permit_params in_birth: [:era, :year, :month, :day]
      before_validation :normalize_in_birth
      validates :sex, inclusion: { in: %w(male female), allow_blank: true }
      validates_with Member::BirthValidator, attributes: :in_birth, if: ->{ in_birth.present? }
      before_save :set_birthday, if: ->{ in_birth.present? }
    end

    def sex_options
      %w(male female).map { |m| [ I18n.t("member.options.sex.#{m}"), m ] }.to_a
    end

    def age(now = Time.zone.now)
      return nil if birthday.blank?
      return nil if now < birthday
      (now.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10_000
    end

    private
      def normalize_in_birth
        return if in_birth.blank?
        self.in_birth = in_birth.select { |_, value| value.present? }
      end

      def set_birthday
        era = in_birth[:era]
        year = in_birth[:year].to_i
        month = in_birth[:month].to_i
        day = in_birth[:day].to_i

        wareki = SS.config.ss.wareki[era]
        return nil if wareki.blank?
        min = Date.parse(wareki['min'])

        self.birthday = Date.new(min.year + year - 1, month, day)
      end
  end
end
