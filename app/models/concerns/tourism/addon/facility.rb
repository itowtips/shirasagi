module Tourism::Addon
  module Facility
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      belongs_to :facility, class_name: "Facility::Node::Page"
      permit_params :facility_id
      validates :facility_id, presence: true
    end

    private

    def template_variable_handler_class_categories(name, issuer)
      labels = []

      label = super(name, issuer)
      labels << label if label.present?

      labels << "facility-#{facility.basename}" if facility
      labels.join(" ")
    end
  end
end
