class JobDb::Incident::Base
  extend SS::Translation
  include SS::Document
  include JobDb::Referenceable
  include SS::Addon::Markdown
  include JobDb::Addon::File
  # include JobDb::Incident::DescendantsFileInfo
  include JobDb::Addon::Incident::Category
  include JobDb::Addon::ReadableSetting
  include JobDb::Addon::GroupPermission
  include JobDb::Addon::History

  store_in collection: "job_db_incidents"
  set_permission_name "job_db_incidents"

  attr_accessor :cur_user

  # seqid :id
  field :name, type: String
  belongs_to :parent, class_name: "JobDb::Incident::Base", inverse_of: :children

  validates :name, presence: true, length: { maximum: 80 }

  permit_params :name

  class << self
    def search(params = {})
      # TODO: implementation
      all
    end
  end
end
