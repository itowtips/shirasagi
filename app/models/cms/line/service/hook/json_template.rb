module Cms::Line::Service::Hook
  class JsonTemplate < Base
    include Cms::Addon::Line::Template::JsonBody

    field :json_body, type: String
    permit_params :json_body
    validate :validate_json_body

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
end
