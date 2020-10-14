module Ezine::Addon
  module AdditionalAttributes
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :live, type: SS::Extensions::Words, default: 'all'
      field :ages, type: SS::Extensions::Words, default: 'all'

      attr_accessor :live_required, :ages_required

      permit_params live: [], ages: []

      validates :live, presence: true, if: ->{ live_required }
      validates :ages, presence: true, if: ->{ ages_required }
    end

    def live_options
      %w(city outside_city).map { |m| [ I18n.t("ezine.options.live.#{m}"), m ] }.to_a
    end

    def ages_options
      %w(10s 20s 30s 40s 50s 60s).map { |m| [ I18n.t("ezine.options.ages.#{m}"), m ] }.to_a
    end

    def set_required(node)
      super
      self.live_required = node.live_required?
      self.ages_required = node.ages_required?
    end
  end
end
