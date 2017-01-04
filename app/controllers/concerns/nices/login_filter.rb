module Nices::LoginFilter
  extend ActiveSupport::Concern
  include Member::AuthFilter
  include Member::LoginFilter

  private
    def member_login_node
      @member_login_node ||= begin
        node = Member::Node::Login.site(@cur_site).and_public.first
        node.present? ? node : false
      end
    end

    def member_login_path
      return false unless member_login_node
      "#{member_login_node.url}login.html"
    end

    def student_mypage_url
      node = Nices::Node::Mypage.site(@cur_site).where(member_kind: "student").first
      node.url
    end

    def teacher_mypage_url
      node = Nices::Node::Mypage.site(@cur_site).where(member_kind: "teacher").first
      node.url
    end

    def redirect_url
      if @cur_member.member_kind == "student"
        student_mypage_url
      else
        teacher_mypage_url
      end
    end
end
