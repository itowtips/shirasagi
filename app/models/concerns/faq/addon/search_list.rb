module Faq::Addon
  module SearchList
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :search_page_model
      permit_params :search_page_model
    end

    def search_page_model_options
      I18n.t("faq.options.search_page_model").map { |k, v| [v, k] }
    end
  end
end
