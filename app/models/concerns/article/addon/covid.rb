module Article::Addon
  module Covid
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :index_covid_name, type: String
      permit_params :index_covid_name

      template_variable_handler(:index_covid_name) { |name, issuer| template_variable_handler_name(:name_for_index_covid, issuer) }

      liquidize do
        export :index_covid_name
      end
    end

    def name_for_index_covid
      index_covid_name || index_name || name
    end
  end
end
