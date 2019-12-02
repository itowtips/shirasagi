class Translate::TextCache
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_tools", :use

  index({ site_id: 1, hexdigest: 1 })

  attr_accessor :key

  field :api, type: String
  field :text, type: String, metadata: { normalize: false }
  field :original_text, type: String
  field :source, type: String
  field :target, type: String
  field :hexdigest, type: String

  validates :api, presence: true
  validates :original_text, presence: true
  validates :source, presence: true
  validates :target, presence: true
  validates :hexdigest, presence: true

  default_scope -> { order_by(updated: -1) }

  class << self
    def search(params = {})
      criteria = self.where({})
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
