FactoryGirl.define do
  trait :cms_role do
    site_id { cur_site ? cur_site.id : cms_site.id }
    user_id { cur_user ? cur_user.id : cms_user.id }
    name "cms_role"
    permissions []
    permission_level 1
  end

  factory :cms_role, class: Cms::Role, traits: [:cms_role] do
    permissions ["release_private_cms_pages"]
  end

  factory :cms_role_admin, class: Cms::Role do
    name "cms_role_admin"
    permissions Cms::Role.permission_names
    site_id 1
  end
end
