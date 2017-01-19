class JobDb::Incident::Topic < JobDb::Incident::Base

  field :state, type: String
  field :descendants_updated, type: DateTime
  has_many :children, class_name: "JobDb::Incident::Comment", dependent: :destroy, inverse_of: :parent, order: { created: -1 }

  validates :descendants_updated, datetime: true
end
