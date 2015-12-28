module Facility::Addon
  module SyncInstitution
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :institution_state, type: String, default: "none"
      permit_params :institution_state
    end

    def institution_supported?
      institution_state == "supported"
    end
  end
end
