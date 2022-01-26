module Webmail::Reference::User
  extend ActiveSupport::Concern
  extend SS::Translation

  attr_accessor :cur_user

  included do
    field :user_uid, type: String
    field :user_name, type: String
    field :user_i18n_name, type: String, localize: true
    belongs_to :user, class_name: "SS::User"

    before_validation :set_user_id, if: ->{ @cur_user }

    scope :user, ->(user) { where(user_id: user.id) }
  end

  def user_uid
    self[:user_uid] || user.try(:uid)
  end

  # def user_name
  #   self[:user_name] || user.try(:name)
  # end
  def user_i18n_name
    self[:user_i18n_name] || user.try(:i18n_name)
  end
  alias user_name user_i18n_name

  def user_tel
    user ? user.try(:tel_label) : nil
  end

  # def user_long_name
  #   return "#{user_name} (#{user_uid})" if user_uid.present?
  #   return user.long_name if user.present?
  #   user_name
  # end
  def user_i18n_long_name
    return "#{user_i18n_name} (#{user_uid})" if user_uid.present?
    return user.i18n_long_name if user.present?
    user_i18n_name
  end
  alias user_long_name user_i18n_long_name

  private

  def set_user_id
    return if user_id.present?

    self.user_id   = @cur_user.id
    self.user_uid  = @cur_user.uid unless self[:user_uid]
    self.user_name = @cur_user.name unless self[:user_name]
    self.user_i18n_name_translations = @cur_user.i18n_name_translations unless self[:user_i18n_name]
  end
end
