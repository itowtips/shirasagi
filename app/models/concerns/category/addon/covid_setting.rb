module Category::Addon
  module CovidSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      belongs_to :st_covid_category, class_name: "Category::Node::Base"
      permit_params :st_covid_category_id
    end
  end
end
