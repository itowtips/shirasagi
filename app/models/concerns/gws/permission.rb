module Gws::Permission
  extend ActiveSupport::Concern
  include SS::Permission

  # Check permission of show, edit, update or delete
  # @return [true|false]
  # @param [Symbol] action :read, :edit or :delete
  # @param [Gws::User] user
  def allowed?(action, user)
    # TODO Implement
    true
  end

  module ClassMethods
    # Check permission of index, new or create
    # @return [true|false]
    # @param [Symbol] action :read or :edit
    # @param [Gws::User] user
    def allowed?(action, user)
      # TODO Implement
      true
    end
  end
end
