module Board::Addon
  module GooglePersonFinderSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :gpf_state, type: String
      field :gpf_repository, type: String
      field :gpf_domain_name, type: String
      field :gpf_api_key, type: String
      attr_accessor :in_gpf_api_key

      permit_params :gpf_state, :gpf_repository, :gpf_domain_name, :in_gpf_api_key

      before_validation :set_gpf_api_key
      validates :gpf_state, inclusion: { in: %w(enabled disabled) }, if: ->{ gpf_state.present? }
    end

    def accessor
      Google::PersonFinder.new(repository: gpf_repository, domain_name: gpf_domain_name, api_key: SS::Crypt.decrypt(gpf_api_key))
    end

    def gpf_state_options
      %w(disabled enabled).map { |m| [ I18n.t("board.options.gpf_state.#{m}"), m ] }.to_a
    end

    private
      def set_gpf_api_key
        self.gpf_api_key = SS::Crypt.encrypt(in_gpf_api_key) if in_gpf_api_key.present?
      end
  end
end
