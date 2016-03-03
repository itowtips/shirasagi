module Member::Addon
  module MemberInvitationSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :member_invitation_subject, type: String
      field :member_invitation_template, type: String
      field :member_invitation_signature, type: String
      permit_params :member_invitation_subject
      permit_params :member_invitation_template
      permit_params :member_invitation_signature
    end
  end
end
