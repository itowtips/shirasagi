class Cms::Line::TestMember
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Addon::GroupPermission

  set_permission_name "cms_line_templates"

  seqid :id
  field :name, type: String
  field :oauth_id, type: String

  permit_params :name, :oauth_id

  validates :name, presence: true
  validates :oauth_id, presence: true

  default_scope -> { order_by(name: 1) }

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
