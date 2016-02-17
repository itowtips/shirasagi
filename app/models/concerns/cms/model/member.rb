module Cms::Model::Member
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  attr_accessor :in_password
  attr_accessor :email_again
  attr_accessor :skip_verification_mail

  OAUTH_PROVIDER_TWITTER = 'twitter'.freeze
  OAUTH_PROVIDER_FACEBOOK = 'facebook'.freeze
  OAUTH_PROVIDER_YAHOOJP = 'yahoojp'.freeze
  OAUTH_PROVIDER_GOOGLE_OAUTH2 = 'google_oauth2'.freeze
  OAUTH_PROVIDER_GITHUB = 'github'.freeze
  OAUTH_PROVIDERS = [ OAUTH_PROVIDER_TWITTER, OAUTH_PROVIDER_FACEBOOK, OAUTH_PROVIDER_YAHOOJP,
                      OAUTH_PROVIDER_GOOGLE_OAUTH2, OAUTH_PROVIDER_GITHUB ].freeze

  included do
    store_in collection: "cms_members"
    set_permission_name "cms_members", :edit

    seqid :id
    field :name, type: String
    field :email, type: String
    field :email_type, type: String
    field :password, type: String
    field :state, type: String
    field :oauth_type, type: String
    field :oauth_id, type: String
    field :oauth_token, type: String
    field :site_email, type: String
    field :last_loggedin, type: DateTime
    field :verification_token, type: String

    permit_params :name, :email, :email_again, :email_type, :password, :in_password, :state
    permit_params interest_municipality_ids: []

    validates :email, email: true, length: { maximum: 80 }
    validates :email, uniqueness: { scope: :site_id }, presence: true, if: ->{ oauth_type.blank? }
    validates :email_type, inclusion: { in: %w(text html) }
    validates :password, presence: true, if: ->{ oauth_type.blank? && enabled? }
    validates :verification_token, uniqueness: { scope: :site_id }, allow_nil: true
    validate :validate_password, if: ->{ in_password.present? }

    before_validation :encrypt_password, if: ->{ in_password.present? }
    before_save :set_site_email, if: ->{ email.present? }

    before_create :set_verification_token, if: ->{ oauth_type.blank? }
    after_create :send_verification_mail, if: ->{ oauth_type.blank? }

    scope :and_enabled, -> { self.or({ state: 'enabled' }, { state: nil }) }
  end

  def encrypt_password
    self.password = SS::Crypt.crypt(in_password)
  end

  def enabled?
    state.nil? || state == 'enabled'
  end

  # 本登録済みかどうか
  def authorized?
    self.verification_token.nil?
  end

  def email_type_options
    %w(text html).map { |m| [ I18n.t("cms.options.email_type.#{m}"), m ] }.to_a
  end

  def state_options
    %w(disabled enabled).map { |m| [ I18n.t("cms.options.member_state.#{m}"), m ] }.to_a
  end

  # 関連するデータの削除
  def delete_leave_member_data(site)
    photos = Member::Photo.site(site).member(self)
    blog_node = Member::Node::Blog.site(site).first
    blog_page_node = Member::Node::BlogPage.site(site).node(blog_node).member(self).first

    photos.each { |p| p.destroy } if photos
    blog_page_node.destroy if blog_page_node
  end

  private
    def set_site_email
      self.site_email = "#{site_id}_#{email}"
    end

    def unique_token
      loop do
        t = Digest::SHA1.hexdigest SecureRandom.uuid
        return t if Cms::Member.where(verification_token: t).first.nil?
      end
    end

    def set_verification_token
      self.verification_token = unique_token if self.skip_verification_mail.nil?
    end

    def send_verification_mail
      Member::Mailer.verification_mail(self).deliver_now if self.skip_verification_mail.nil?
    end

    def validate_password
      errors.add :in_password, :password_short if self.in_password.length < 6
      errors.add :in_password, :password_alphabet_only if self.in_password =~ /[A-Z]/i && self.in_password !~ /[^A-Z]/i
      errors.add :in_password, :password_numeric_only if self.in_password =~ /[0-9]/ && self.in_password !~ /[^0-9]/
      errors.add :in_password, :password_include_email if self.in_password =~ /#{Regexp.escape(self.email)}/
      errors.add :in_password, :password_include_name if self.in_password =~ /#{Regexp.escape(self.name)}/
    end
end
