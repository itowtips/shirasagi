class Cms::GenerateTask
  include SS::Model::Task

  belongs_to :node, class_name: "Cms::Node"

  field :generate_key, type: String

  validates :site_id, presence: true
end
