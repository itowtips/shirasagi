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
      permit_params :kana, :tel, :addr, :sex, :birthday
      validates :sex, inclusion: { in: %w(male female), allow_blank: true }
    end

    def sex_options
      %w(male female).map { |m| [ I18n.t("member.options.sex.#{m}"), m ] }.to_a
    end

    def age(now = Time.zone.now)
      birthday ? (now.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10_000 : nil
    end
  end
end
