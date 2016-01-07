module Cms::MemberPermission
  extend ActiveSupport::Concern

  public
    def allowed?(action, member, opts = {})
      return true if new_record?
      member_id == member.id
    end

  module ClassMethods
    public
      def allowed?(action, member, opts = {})
        self.new.allowed?(action, member, opts)
      end

      def allow(action, member, opts = {})
        where(member_id: member.id)
      end
  end
end
