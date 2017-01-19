class JobDb::Incident::Topic < JobDb::Incident::Base
  # include JobDb::Incident::DescendantsFileInfo
  include JobDb::Addon::Incident::Category
  include JobDb::Addon::ReadableSetting
  include JobDb::Addon::GroupPermission

  field :name, type: String
  field :descendants_updated, type: DateTime

  has_many :descendants, class_name: "JobDb::Incident::Comment", dependent: :destroy, inverse_of: :topic, order: { created: -1 }
  has_many :children, class_name: "JobDb::Incident::Comment", dependent: :destroy, inverse_of: :parent, order: { created: -1 }

  validates :name, presence: true, length: { maximum: 80 }
  validates :descendants_updated, datetime: true
  before_save :set_descendants_updated

  permit_params :name

  private
    def set_descendants_updated
      self.descendants_updated = updated || Time.zone.now
    end
end
