class Member::BlogPage
  include SS::Document
  include SS::Translation
  include SS::Reference::Site
  include SS::Reference::User
  include Cms::Reference::Member
  #include Cms::Reference::Node
  include Member::Reference::Blog
  include Member::Addon::Blog::Body
  include Member::Addon::File
  include Member::Addon::Blog::Genre
  include Cms::Addon::GroupPermission

  set_permission_name "member_blogs"

  seqid :id
  store_in collection: "member_blog_pages"

  field :name, type: String
  field :released, type: DateTime
  field :state, type: String, default: "public"

  permit_params :name, :released, :state
  permit_params genres: []

  validates :name, presence: true, length: { maximum: 80 }
  after_validation :set_released, if: -> { public? }

  public
    def public?
      state == "public"
    end

    def date
      released || updated || created
    end

    def url(node)
      "#{node.url}#{blog.id}/page/#{id}/"
    end

    def full_url(node)
      ::File.join(site.full_url, url(node))
    end

    def state_options
      [
        [I18n.t('views.options.state.public'), 'public'],
        [I18n.t('views.options.state.closed'), 'closed'],
      ]
    end

  private
    def set_released
      self.released ||= Time.zone.now
    end

  class << self
    def public
      where state: "public"
    end

    def search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:g].present?
        criteria = criteria.in(genres: params[:g])
      end
      criteria
    end
  end
end
