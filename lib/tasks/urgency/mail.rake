namespace :urgency do
  task :mail => :environment do
    site = Cms::Site.where(host: ENV['site']).first
    #data = STDIN.read
    data = %Q(
From root@localhost.localdomain Thu May 19 14:09:13 2016
Return-Path: <root@localhost.localdomain>
X-Original-To: root@localhost
Delivered-To: root@localhost.localdomain
Received: by localhost.localdomain (Postfix, from userid 0)
id E968A35A5FF4; Thu, 19 May 2016 14:09:13 +0900 (JST)
From: ito@localhost.localdomain
To: root@localhost.localdomain
Subject: To my brother.
Message-Id: <20160519050913.E968A35A5FF4@localhost.localdomain>
Date: Thu, 19 May 2016 14:09:08 +0900 (JST)

Hello, brother!
Are you there.
)

    mail = ::Mail.new(data)
    to = mail.to[0]
    puts to

    Urgency::Node::Page.site(site).in(receive_email: to).each do |node|
      node.create_page_from_mail(mail)
    end
  end
end
