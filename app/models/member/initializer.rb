module Member
  class Initializer
    # login node
    Cms::Node.plugin "member/login"

    # mypage nodes
    Cms::Node.plugin "member/mypage"
    Cms::Node.plugin "member/my_blog"
    Cms::Node.plugin "member/my_photo"

    # public nodes
    Cms::Node.plugin "member/blog"
    Cms::Node.plugin "member/photo"
    Cms::Node.plugin "member/photo_search"
    Cms::Node.plugin "member/photo_category"
    Cms::Node.plugin "member/photo_location"
    Cms::Node.plugin "member/photo_spot"

    Cms::Part.plugin "member/photo_slide"

    Cms::Role.permission :read_other_member_blogs
    Cms::Role.permission :read_private_member_blogs
    Cms::Role.permission :edit_other_member_blogs
    Cms::Role.permission :edit_private_member_blogs
    Cms::Role.permission :delete_other_member_blogs
    Cms::Role.permission :delete_private_member_blogs
    Cms::Role.permission :release_other_member_blogs
    Cms::Role.permission :release_private_member_blogs

    Cms::Role.permission :read_other_member_photos
    Cms::Role.permission :read_private_member_photos
    Cms::Role.permission :edit_other_member_photos
    Cms::Role.permission :edit_private_member_photos
    Cms::Role.permission :delete_other_member_photos
    Cms::Role.permission :delete_private_member_photos
    Cms::Role.permission :release_other_member_photos
    Cms::Role.permission :release_private_member_photos
  end
end
