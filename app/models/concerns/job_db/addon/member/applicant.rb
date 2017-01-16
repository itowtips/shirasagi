module JobDb::Addon::Member::Applicant
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    embeds_ids :kinds, class_name: "JobDb::Member::Kind"
    permit_params kind_ids: []
  end
end
