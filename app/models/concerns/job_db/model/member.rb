module JobDb::Model::Member
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Model::Member
  include JobDb::Addon::Member::Applicant

  included do
    store_in collection: "job_db_members"
  end
end
