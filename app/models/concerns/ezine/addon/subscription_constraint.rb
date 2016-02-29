module Ezine::Addon
  module SubscriptionConstraint
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :subscription_constraint, type: String
      validates :subscription_constraint, inclusion: { in: %w(required non_required) },
                if: ->{ subscription_constraint.present? }
      permit_params :subscription_constraint
      after_save :update_members_subscription
      scope :and_subscription_required, ->{ where(subscription_constraint: 'required') }
    end

    private
      def update_members_subscription
        return unless subscription_requried?

        Cms::Member.site(site).each do |member|
          subscription_ids = member.subscription_ids
          subscription_ids ||= []
          subscription_ids << self.id
          subscription_ids = subscription_ids.uniq
          member.subscription_ids = subscription_ids
          member.save!
        end
      end

    public
      def subscription_constraint_options
        %w(non_required required).map { |m| [ I18n.t("ezine.options.subscription_constraint.#{m}"), m ] }.to_a
      end

      def subscription_requried?
        subscription_constraint == 'required'
      end
  end
end
