module Board::Addon
  module MapSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :map_state, type: String
      field :map_zoom_level, type: Integer
      field :map_center, type: Map::Extensions::Loc, default: ->{ SS.config.cms.map_center }

      permit_params :map_state, :map_zoom_level
      permit_params map_center: [ :lat, :lng ]

      validates :map_state, inclusion: { in: %w(enabled disabled) }, if: ->{ gpf_state.present? }
      validates :map_zoom_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 18, allow_nil: true }
    end

    def map_state_options
      %w(disabled enabled).map { |m| [ I18n.t("board.options.map_state.#{m}"), m ] }.to_a
    end

    def map_enabled?
      gpf_state == 'enabled'
    end
  end
end
