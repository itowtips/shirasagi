module JobDb::GroupPermission
  extend ActiveSupport::Concern
  include SS::Permission

  included do
    field :permission_level, type: Integer, default: 1
    embeds_ids :groups, class_name: "SS::Group"
    embeds_ids :users, class_name: "SS::User"
    permit_params :permission_level, group_ids: [], user_ids: []
  end

  module ClassMethods
    # @param [String] action
    # @param [SS::User | Cms::User] user
    def allow(action, user, opts = {})
      where(allow_condition(action, user, opts))
    end

    def allow_condition(action, user, opts = {})
      action = permission_action || action

      if level = user.sys_role_permissions["#{action}_other_#{permission_name}"]
        { "$or" => [
            { user_ids: user.id },
            { permission_level: { "$lte" => level } },
        ] }
      elsif level = user.sys_role_permissions["#{action}_private_#{permission_name}"]
        { "$or" => [
            { user_ids: user.id },
            { :group_ids.in => user.group_ids, "$or" => [{ permission_level: { "$lte" => level } }] }
        ] }
      else
        { user_ids: user.id }
      end
    end
  end

  def owned?(user)
    return true if (self.group_ids & user.group_ids).present?
    return true if user_ids.to_a.include?(user.id)
    false
  end

  # def permission_level_options
  #   [%w(1 1), %w(2 2), %w(3 3)]
  # end

  # @param [String] action
  # @param [Gws::User] user
  def allowed?(action, user, opts = {})
    return true if !new_record? && user_ids.to_a.include?(user.id)

    action  = permission_action || action

    permits = ["#{action}_other_#{self.class.permission_name}"]
    permits << "#{action}_private_#{self.class.permission_name}" if owned?(user) || new_record?

    permits.each do |permit|
      return true if user.sys_role_permissions[permit].to_i > 0
    end
    false
  end
end
