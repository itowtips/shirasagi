module Member::Addon::Photo
  module PippiLicense
    extend ActiveSupport::Concern
    extend SS::Addon
    include SS::Relation::File

    included do
      field :download_state, type: String
      field :pippi_license, type: String
      field :license_html, type: String
      belongs_to_file2 :license_image
      permit_params :download_state, :pippi_license, :license_html

      validates :download_state, presence: true
    end

    def download_state_options
      %w(enabled disabled).map do |v|
        [ I18n.t("ss.options.state.#{v}"), v ]
      end
    end

    def pippi_license_options
      [
        %w(CC-BY cc_by)
      ]
    end
  end
end
