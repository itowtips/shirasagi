module Member
  class Initializer
    # login node
    Cms::Node.plugin "member/login"

    # mypage nodes
    Cms::Node.plugin "member/mypage"
    Cms::Node.plugin "member/my_blog"

    # public nodes
    Cms::Node.plugin "member/blog"

    Cms::Role.permission :read_other_member_blogs
    Cms::Role.permission :read_private_member_blogs
    Cms::Role.permission :edit_other_member_blogs
    Cms::Role.permission :edit_private_member_blogs
    Cms::Role.permission :delete_other_member_blogs
    Cms::Role.permission :delete_private_member_blogs
  end
end
