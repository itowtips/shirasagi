module JobDb::Addon::ReadableSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    class_variable_set(:@@_readable_setting_include_custom_groups, nil)

    embeds_ids :readable_groups, class_name: "SS::Group"
    embeds_ids :readable_users, class_name: "SS::User"

    permit_params readable_group_ids: [], readable_user_ids: []

    # Allow readable settings and readable permissions.
    scope :readable, ->(user, opts = {}) {
      cond = [
          { "readable_group_ids.0" => { "$exists" => false },
            "readable_user_ids.0" => { "$exists" => false } },
          { :readable_group_ids.in => user.group_ids },
          { readable_user_ids: user.id },
      ]

      cond << allow_condition(:read, user) if opts[:include_role]
      where("$and" => [{ "$or" => cond }])
    }
  end

  def readable_setting_present?
    return true if readable_group_ids.present?
    return true if readable_user_ids.present?
    false
  end

  def readable?(user)
    return true if readable_group_ids.blank? && readable_user_ids.blank?
    return true if readable_group_ids.any? { |m| user.group_ids.include?(m) }
    return true if readable_user_ids.include?(user.id)
    return true if allowed?(:read, user, site: site) # valid role
    false
  end

  # def readable_groups_hash
  #   self[:readable_groups_hash].presence || readable_groups.map { |m| [m.id, m.name] }.to_h
  # end

  # def readable_group_names
  #   readable_groups_hash.values
  # end
  def readable_group_names
    @readable_group_names ||= readable_groups.pluck(:name)
  end

  # def readable_users_hash
  #   self[:readable_users_hash].presence || readable_users.map { |m| [m.id, m.long_name] }.to_h
  # end
  #
  # def readable_user_names
  #   readable_users_hash.values
  # end
  def readable_user_names
    @readable_user_names ||= readable_users.pluck(:name)
  end

  private
    # def set_readable_groups_hash
    #   self.readable_groups_hash = readable_groups.map { |m| [m.id, m.name] }.to_h
    # end

    # def set_readable_users_hash
    #   self.readable_users_hash = readable_users.map { |m| [m.id, m.long_name] }.to_h
    # end

    # def set_readable_custom_groups_hash
    #   self.readable_custom_groups_hash = readable_custom_groups.map { |m| [m.id, m.name] }.to_h
    # end

  # module ClassMethods
  #   def readable_setting_included_custom_groups?
  #     class_variable_get(:@@_readable_setting_include_custom_groups)
  #   end
  #
  #   private
  #   def readable_setting_include_custom_groups
  #     class_variable_set(:@@_readable_setting_include_custom_groups, true)
  #   end
  # end
end
