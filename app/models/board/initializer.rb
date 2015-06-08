module Board
  class Initializer
    Gws::Role.permission :read_other_board_posts
    Gws::Role.permission :read_private_board_posts
    Gws::Role.permission :edit_other_board_posts
    Gws::Role.permission :edit_private_board_posts
    Gws::Role.permission :delete_other_board_posts
    Gws::Role.permission :delete_private_board_posts
  end
end
