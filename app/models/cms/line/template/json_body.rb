class Cms::Line::Template::JsonBody < Cms::Line::Template::Base
  include Cms::Addon::Line::Template::JsonBody

  field :json_body, type: String
  permit_params :json_body
  validate :validate_json_body

  def type
    "json_body"
  end

  def balloon_html
    h = []
    h << '<div class="talk-balloon">'
    h << '<div style="font-weight: bold;">{JSONテンプレート;}</div>'
    h << '</div>'
    h.join
  end

  def body
    ::JSON.parse(json_body)
  end

  private

  def validate_json_body
    if json_body.blank?
      errors.add :json_body, :blank
      return
    end

    begin
      body
    rescue JSON::ParserError => e
      errors.add :json_body, :invalid
    end
  end
end
