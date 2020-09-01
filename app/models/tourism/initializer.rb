module Tourism
  class Initializer
    Cms::Node.plugin "tourism/page"
    Cms::Node.plugin "tourism/notice"
    Cms::Node.plugin "tourism/map"

    Cms::Role.permission :read_other_tourism_pages
    Cms::Role.permission :read_private_tourism_pages
    Cms::Role.permission :edit_other_tourism_pages
    Cms::Role.permission :edit_private_tourism_pages
    Cms::Role.permission :delete_other_tourism_pages
    Cms::Role.permission :delete_private_tourism_pages
    Cms::Role.permission :unlock_other_tourism_pages
    Cms::Role.permission :release_other_tourism_pages
    Cms::Role.permission :release_private_tourism_pages
    Cms::Role.permission :approve_other_tourism_pages
    Cms::Role.permission :approve_private_tourism_pages
    Cms::Role.permission :reroute_other_tourism_pages
    Cms::Role.permission :reroute_private_tourism_pages
    Cms::Role.permission :revoke_other_tourism_pages
    Cms::Role.permission :revoke_private_tourism_pages

    Cms::Role.permission :read_other_tourism_notices
    Cms::Role.permission :read_private_tourism_notices
    Cms::Role.permission :edit_other_tourism_notices
    Cms::Role.permission :edit_private_tourism_notices
    Cms::Role.permission :delete_other_tourism_notices
    Cms::Role.permission :delete_private_tourism_notices
    Cms::Role.permission :unlock_other_tourism_notices
    Cms::Role.permission :release_other_tourism_notices
    Cms::Role.permission :release_private_tourism_notices
    Cms::Role.permission :approve_other_tourism_notices
    Cms::Role.permission :approve_private_tourism_notices
    Cms::Role.permission :reroute_other_tourism_notices
    Cms::Role.permission :reroute_private_tourism_notices
    Cms::Role.permission :revoke_other_tourism_notices
    Cms::Role.permission :revoke_private_tourism_notices

    SS::File.model "tourism/page", SS::File
    SS::File.model "tourism/notice", SS::File
  end
end
