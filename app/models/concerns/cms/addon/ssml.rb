module Cms::Addon
  module Ssml
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :ssml, type: String
      permit_params :ssml
      validate :validate_ssml
    end

    private

    def validate_ssml
      return if ssml.blank?
      self.ssml = ssml.gsub("\r\n", "\n")
    end
  end
end
