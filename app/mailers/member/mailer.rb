class Member::Mailer < ActionMailer::Base
  # 会員登録に対して確認メールを配信する。
  #
  # @param [Cms::Member] member
  def verification_mail(member)
    @member = member
    @node = Member::Node::Registration.first
    return if @node.blank?
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: member.email
  end

  # パスワードの再設定メールを配信する。
  #
  # @params [Cms::Member] member
  def reset_password_mail(member)
    @member = member
    @node = Member::Node::Registration.first
    return if @node.blank?
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: member.email
  end

  # グループ招待メールを配信する。
  #
  # @param [Cms::Member] member
  def group_invitation_mail(message, member, node)
    @message = message
    @member = member
    @node = node
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: member.email
  end

  # 会員招待メールを配信する。
  #
  # @param [Cms::Member] member
  def member_invitation_mail(message, member, node)
    @message = message
    @member = member
    @node = node
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: member.email
  end
end
