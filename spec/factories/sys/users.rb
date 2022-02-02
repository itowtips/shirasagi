FactoryBot.define do
  factory :sys_user, class: SS::User do
    name { "sys_user" }
    email { "sys@example.jp" }
    in_password { "pass" }
    deletion_lock_state { "locked" }
    #sys_role_ids

    lang { I18n.locale.to_s }
  end

  factory :sys_user_sample, class: SS::User do
    name { unique_id.to_s }
    email { "user#{unique_id}@example.jp" }
    in_password { "pass" }
    #sys_role_ids

    lang { I18n.locale.to_s }
  end
end
