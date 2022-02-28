class Gws::Bookmark
  include SS::Document
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::SitePermission

  BOOKMARK_MODEL_TYPES = %w(
    portal reminder bookmark schedule memo board faq qna report workflow
    circular discussion monitor share shared_address elasticsearch staff_record
  ).freeze

  set_permission_name 'gws_bookmarks', :edit

  seqid :id
  field :name, type: String
  field :url, type: String
  field :bookmark_model, type: String

  permit_params :name, :url, :bookmark_model

  # 200 = 80 for japanese name + 120 for english name
  # 日本語タイトルと英語タイトルとをスラッシュで連結して、一つのページとして運用することを想定
  validates :name, presence: true, length: { maximum: 200 }
  validates :url, presence: true
  validates :bookmark_model, presence: true, inclusion: { in: (%w(other) << BOOKMARK_MODEL_TYPES).flatten }

  scope :search, ->(params) {
    criteria = where({})
    return criteria if params.blank?

    criteria = criteria.keyword_in params[:keyword], :name if params[:keyword].present?
    criteria = criteria.where(bookmark_model: params[:bookmark_model]) if params[:bookmark_model].present?
    criteria
  }

  default_scope ->{ order_by(updated: -1) }

  def bookmark_model_options
    options = BOOKMARK_MODEL_TYPES.map do |model_type|
      [@cur_site.try(:"menu_#{model_type}_label") || I18n.t("modules.gws/#{model_type}"), model_type]
    end
    options.push([I18n.t('gws/bookmark.options.bookmark_model.other'), 'other'])
  end
end
