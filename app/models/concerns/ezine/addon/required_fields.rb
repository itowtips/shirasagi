module Ezine::Addon
  module RequiredFields
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :live_required, type: String, default: "optional"
      field :ages_required, type: String, default: "optional"
      validates :live_required, inclusion: { in: %w(optional required), allow_blank: true }
      validates :ages_required, inclusion: { in: %w(optional required), allow_blank: true }
      permit_params :live_required, :ages_required
    end

    def live_required_options
      %w(optional required).map do |v|
        [ I18n.t("inquiry.options.required.#{v}"), v ]
      end
    end
    alias ages_required_options live_required_options

    def live_required?
      live_required == 'required'
    end

    def ages_required?
      ages_required == 'required'
    end
  end
end
