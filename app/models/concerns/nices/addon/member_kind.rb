module Nices::Addon
  module MemberKind
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :member_kind, type: String

      validates :member_kind, inclusion: { in: %w(student teacher) }

      permit_params :member_kind
    end

    def member_kind_options
      [
        ["学生", "student"],
        ["教員", "teacher"],
      ]
    end

    #module ClassMethods
    #end
  end
end
