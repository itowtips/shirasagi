class Gws::ImageResize
  include SS::Model::ImageResize
  include Gws::Referenceable
  include Gws::Reference::Site
  include Gws::SitePermission

  set_permission_name 'gws_contrasts', :edit
end
