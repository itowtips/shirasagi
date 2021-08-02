class Cms::Line::Message
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
