gws_admin_role = Gws::Role.create(
  name: "GWS管理者",
  permission_level: 3,
  permissions: %w(
    read_gws_users
    edit_gws_users

    read_other_board_posts
    read_private_board_posts
    edit_other_board_posts
    edit_private_board_posts
    delete_other_board_posts
    delete_private_board_posts

    read_other_schedule_plans
    read_private_schedule_plans
    edit_other_schedule_plans
    edit_private_schedule_plans
    delete_other_schedule_plans
    delete_private_schedule_plans

    read_other_reservation_plans
    read_private_reservation_plans
    edit_other_reservation_plans
    edit_private_reservation_plans
    delete_other_reservation_plans
    delete_private_reservation_plans

    read_other_share_files
    read_private_share_files
    edit_other_share_files
    edit_private_share_files
    delete_other_share_files
    delete_private_share_files
  )
)

admin_user = Gws::User.find_by uid: "admin"
admin_user.update gws_role_ids: [gws_admin_role.id]
