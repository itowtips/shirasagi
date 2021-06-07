class Cms::Line::Template
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  seqid :id
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
    json
  rescue JSON::ParserError => e
    errors.add :base, "#{t(:body)}#{I18n.t("errors.messages.invalid")} #{e.to_s}"
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
