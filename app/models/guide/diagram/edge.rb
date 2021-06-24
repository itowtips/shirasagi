class Guide::Diagram::Edge
  include SS::Document

  field :value, type: String
  field :transition, type: String
  field :question_type, type: String

  validates :value, presence: true
  validates :transition, presence: true
  validates :question_type, presence: true

  embeds_ids :points, class_name: "Guide::Diagram::Point"

  def export_label
    "[選択肢] #{value}"
  end

  def procedures
    points.where(_type: "Guide::Procedure")
  end

  def questions
    points.where(_type: "Guide::Question")
  end
end
