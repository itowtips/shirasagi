class Gws::Link
  include SS::Document
  include Gws::Referenceable
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::Addon::Link
  include SS::Addon::Release
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  include Gws::Addon::History

  seqid :id
  field :name, type: String

  permit_params :name

  # 200 = 80 for japanese name + 120 for english name
  # 日本語タイトルと英語タイトルとをスラッシュで連結して、一つのページとして運用することを想定
  validates :name, presence: true, length: { maximum: 200 }

  default_scope -> {
    order_by released: -1
  }
  scope :search, ->(params) {
    criteria = where({})
    return criteria if params.blank?

    criteria = criteria.keyword_in params[:keyword], :name, :html if params[:keyword].present?
    criteria
  }
end
