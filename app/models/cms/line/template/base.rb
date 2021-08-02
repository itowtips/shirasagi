class Cms::Line::Template::Base
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  set_permission_name "cms_line_templates"

  field :name, type: String
  field :body, type: String

  permit_params :name, :body

  validates :name, presence: true
  validate :validate_body

  def json
    JSON.parse(body)
  end

  private

  def validate_body
    if body.blank?
      errors.add :body, :blank
      return
    end

    begin
      json
    rescue JSON::ParserError => e
      errors.add :base, "#{t(:body)}#{I18n.t("errors.messages.invalid")} #{e.to_s}"
    end
  end

  class << self
    def search(params)
      criteria = all
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end
  end
end
