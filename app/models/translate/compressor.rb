class Translate::Compressor
  extend SS::Translation
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_tools", :use

  field :css, type: String
  permit_params :css

  validates :css, presence: true
  validate :validate_css, if: ->{ css.present? }

  default_scope -> { order_by(updated: -1) }

  def name
    css
  end

  def validate_css
    Nokogiri.parse("<html></html>").css(css)
  rescue
    self.errors.add :css, :invalid
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
