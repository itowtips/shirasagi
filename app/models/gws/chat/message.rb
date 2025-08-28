module Gws::Chat
  class Message
    include SS::Document
    include Gws::Reference::User
    #include Gws::Reference::Site

    seqid :id
    field :message, type: String

    validates :user_id, presence: true
    validates :message, presence: true

    def html
      h = []
      h << "<div class=\"message-wrap\" data-user=\"#{user.id}\">"
      h << "<header>"
      h << "<div class=\"user\">#{user.name}</div>"
      h << "<time>#{I18n.l(updated, format: :picker)}</time>"
      h << "</header>"
      h << "<div class=\"message\">#{message}</div>"
      h << "</div>"
      h.join.html_safe
    end
  end
end
