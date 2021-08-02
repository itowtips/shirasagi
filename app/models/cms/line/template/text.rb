class Cms::Line::Template::Text < Cms::Line::Template::Base
  field :text, type: String
  permit_params :text

  before_validation :set_body

  validates :name, presence: true

  private

  def set_body
    return if name.blank?
    self.body = {
      type: "text",
      text: text
    }.to_json
  end
end
