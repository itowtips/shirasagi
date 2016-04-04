class Facility::Mailer < ActionMailer::Base
  def update_mail(from, to, node, fields = nil)
    @node = node
    @subject = "[施設更新]#{node.name} - #{node.site.name}"
    @user = "#{node.cur_user.name}(#{node.cur_user.uid})" if node.cur_user
    @fields = fields
    
    mail from: from, to: to
  end
end
