module Member::Addon
  module GroupInvitationSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :group_invitation_subject, type: String
      field :group_invitation_upper_text, type: String
      field :group_invitation_lower_text, type: String
      field :group_invitation_signature, type: String
      permit_params :group_invitation_subject
      permit_params :group_invitation_upper_text
      permit_params :group_invitation_lower_text
      permit_params :group_invitation_signature
    end
  end
end
