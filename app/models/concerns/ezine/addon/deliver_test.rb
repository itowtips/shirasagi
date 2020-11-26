module Ezine::Addon
  module DeliverTest
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :use_groups_email, type: String

      permit_params :use_groups_email
    end

    def use_groups_email_options
      %w(disabled enabled).map do |v|
        [I18n.t("ss.options.state.#{v}"), v]
      end
    end
  end
end
