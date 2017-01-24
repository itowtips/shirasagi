module JobDb::Addon::Member::Applicant
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    embeds_ids :kinds, class_name: "JobDb::Member::Kind"
    permit_params kind_ids: []

    scope :and_kinds, ->(kind_ids) { where(:kind_ids.in => kind_ids) }
  end
end
