class Translate::Compressor
  extend SS::Translation
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_tools", :use

  field :name, type: String
  field :selector, type: String
  field :source, type: String
  field :target, type: String
  field :html, type: String

  permit_params :name
  permit_params :selector
  permit_params :source
  permit_params :target
  permit_params :html

  validates :selector, presence: true
  validate :validate_selector, if: ->{ selector.present? }

  default_scope -> { order_by(updated: -1) }

  def validate_css
    Nokogiri.parse("<html></html>").css(selector)
  rescue
    self.errors.add :selector, :invalid
  end

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
