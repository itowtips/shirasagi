class Cms::Line::DeliverAge
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Addon::Line::DeliverCondition::Model
  include Category::Addon::Setting
  include Cms::SitePermission

  set_permission_name "cms_line_deliver_categories", :use

  seqid :id
  field :name, type: String
  field :order, type: Integer, default: 0
  field :state, type: String, default: 'public'

  permit_params :name, :order, :state

  validates :name, presence: true
  validate :validate_condition_body

  default_scope -> { order_by(order: 1) }

  def state_options
    %w(public closed).map { |v| [ I18n.t("ss.options.state.#{v}"), v ] }
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

    def and_public
      self.where(state: "public")
    end
  end
end
