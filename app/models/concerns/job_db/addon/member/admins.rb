module JobDb::Addon::Member::Admins
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    embeds_ids :members, class_name: "JobDb::Member"
    permit_params member_ids: []
  end
end
