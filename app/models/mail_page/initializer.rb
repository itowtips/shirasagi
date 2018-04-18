module MailPage
  class Initializer
    Cms::Node.plugin "mail_page/page"

    Cms::Role.permission :read_other_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :read_private_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :edit_other_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :edit_private_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :delete_other_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :delete_private_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :release_other_mail_page_pages, module_name: "mail_page"
    Cms::Role.permission :release_private_mail_page_pages, module_name: "mail_page"

    SS::File.model "mail_page/page", SS::File
  end
end
