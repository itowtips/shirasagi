class Pippi::TipsLayout
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Reference::Node
  include Cms::SitePermission
  include Pippi::Addon::TipsFile
  include Cms::Addon::LayoutHtml

  set_permission_name "pippi_tips"

  seqid :id
  field :name, type: String
  field :state, type: String, default: "public"
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  permit_params :name, :start_date, :end_date

  validates :name, presence: true

  default_scope ->{ order_by(start_date: -1) }

  private

  def validate_date
    errors.add :start_date, :blank if start_date.blank?
    errors.add :end_date, :blank if end_date.blank?
    return unless errors.empty?

    if start_date >= end_date
      errors.add :end_date, :greater_than, count: t(:start_date)
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
