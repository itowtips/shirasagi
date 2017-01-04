module Nices
  class Initializer
    Cms::Node.plugin "nices/mypage"
    Cms::Node.plugin "nices/curriculum"
    Cms::Node.plugin "nices/curriculum_checker"

=begin
    Cms::Role.permission :read_other_member_blogs
    Cms::Role.permission :read_private_member_blogs
    Cms::Role.permission :edit_other_member_blogs
    Cms::Role.permission :edit_private_member_blogs
    Cms::Role.permission :delete_other_member_blogs
    Cms::Role.permission :delete_private_member_blogs
    Cms::Role.permission :release_other_member_blogs
    Cms::Role.permission :release_private_member_blogs
    Cms::Role.permission :approve_other_member_blogs
    Cms::Role.permission :approve_private_member_blogs

    Cms::Role.permission :read_other_member_photos
    Cms::Role.permission :read_private_member_photos
    Cms::Role.permission :edit_other_member_photos
    Cms::Role.permission :edit_private_member_photos
    Cms::Role.permission :delete_other_member_photos
    Cms::Role.permission :delete_private_member_photos
    Cms::Role.permission :release_other_member_photos
    Cms::Role.permission :release_private_member_photos

    SS::File.model "member/photo", Member::PhotoFile
=end
  end
end
