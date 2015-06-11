module Share
  class Initializer
    Gws::Role.permission :read_other_share_files
    Gws::Role.permission :read_private_share_files
    Gws::Role.permission :edit_other_share_files
    Gws::Role.permission :edit_private_share_files
    Gws::Role.permission :delete_other_share_files
    Gws::Role.permission :delete_private_share_files
  end
end
