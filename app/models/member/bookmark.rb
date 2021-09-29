class Member::Bookmark
  include SS::Document
  include SS::Reference::Site
  include Cms::Reference::Member

  #set_permission_name "member_blogs"

  belongs_to :page, class_name: "Cms::Page"
end
