class Cms::ImageResize
  include SS::Model::ImageResize
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_tools", :use
end
