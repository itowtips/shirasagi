class Ezine::Mailer < ActionMailer::Base
  # Deliver a verification e-mail to the entry.
  #
  # 購読申し込みに対して確認メールを配信する。
  #
  # @param [Ezine::Entry] entry
  def verification_mail(entry)
    @entry = entry
    @node = Ezine::Node::Page.find entry.node.id
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: entry.email
  end

  # Deliver Ezine::Page as an e-mail.
  #
  # Ezine::Page を E-mail として配信する。
  #
  # @param [Ezine::Page] page
  # @param [Ezine::Member, Ezine::TestMember] member
  def page_mail(page, member, lang = nil)
    @page = page
    @member = member
    @node = Cms::Node.find page.parent.id
    @node = @node.becomes_with_route
    @name = @page.name
    @html = @page.html
    @text = @page.text
    if lang.present?
      @node.signature_html = @node.i18n_signature_html_translations[lang.code].presence || @node.signature_html
      @node.signature_text = @node.i18n_signature_text_translations[lang.code].presence || @node.signature_text
      @node.sender_name = @node.i18n_sender_name_translations[lang.code].presence || @node.sender_name
      @name = @page.i18n_name_translations[lang.code].presence || @page.name
      @html = @page.i18n_html_translations[lang.code].presence || @page.html
      @text = @page.i18n_text_translations[lang.code].presence || @page.text
    end
    sender = "#{@node.sender_name} <#{@node.sender_email}>"

    mail from: sender, to: member.email do |format|
      case member.email_type
      when "text"
        format.text
      when "html"
        # send multipart mail.
        # format order is important. text is first, then html is last
        # see: http://monmon.hatenablog.com/entry/2015/02/02/141722
        format.text
        format.html if @html.present?
      else
        # default
        format.text
      end
    end
  end
end
