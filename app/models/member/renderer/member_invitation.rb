class Member::Renderer::MemberInvitation
  include ActiveModel::Model
  include Member::TemplateVariableRenderer

  attr_accessor :group, :sender, :recipent, :template

  template_variable_handler(:sender_name, :template_variable_handler_sender_name)
  template_variable_handler(:sender_email, :template_variable_handler_sender_email)
  template_variable_handler(:group_name, :template_variable_handler_group_name)
  template_variable_handler(:invitation_message, :template_variable_handler_invitation_message)
  template_variable_handler(:registration_url, :template_variable_handler_registration_url)

  private
    def template_variable_handler_sender_name(*_)
      sender.name
    end

    def template_variable_handler_sender_email(*_)
      sender.email
    end

    def template_variable_handler_group_name(*_)
      group.name
    end

    def template_variable_handler_invitation_message(*_)
      group.invitation_message
    end

    def template_variable_handler_registration_url(*_)
      node = Member::Node::Registration.site(group.site).public.first
      return if node.blank?

      params = {
        token: recipent.verification_token,
      }
      "#{node.full_url}verify?#{params.to_query}"
    end
end
