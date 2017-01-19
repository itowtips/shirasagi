module JobDb::Addon::Incident::Category
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    embeds_ids :categories, class_name: "JobDb::Incident::Category"
    permit_params category_ids: []
  end
end
