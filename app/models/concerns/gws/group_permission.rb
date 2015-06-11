module Gws::GroupPermission
  extend ActiveSupport::Concern
  include SS::Permission

  included do
    field :permission_level, type: Integer, default: 1
    embeds_ids :groups, class_name: "SS::Group"
    permit_params :permission_level, group_ids: []
  end

  public
    def permission_level_options
      [%w(1 1), %w(2 2), %w(3 3)]
    end

    def allowed?(action, user, group)
      # TODO Implement
      true
    end

  module ClassMethods
    public
      def allow(action, user)
        # TODO Implement
        true
      end
  end
end
