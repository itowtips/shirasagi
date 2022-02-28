class Gws::CustomGroup
  include SS::Document
  include SS::Fields::Normalizer
  include Gws::Referenceable
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::Addon::Member
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  include Gws::Addon::History

  # Member addon setting
  keep_members_order

  seqid :id
  field :name, type: String
  field :order, type: Integer, default: 0

  permit_params :name, :order

  # 200 = 80 for japanese name + 120 for english name
  # 日本語タイトルと英語タイトルとをスラッシュで連結して、一つのページとして運用することを想定
  validates :name, presence: true, length: { maximum: 200 }

  default_scope ->{ order_by order: 1 }

  scope :search, ->(params) {
    criteria = where({})
    return criteria if params.blank?

    criteria = criteria.keyword_in params[:keyword], :name if params[:keyword].present?
    criteria
  }
end
