def create_default_portal
  default_portal = Gws::DefaultPortal.new(gws_site)
  default_portal.create_user_preset
  default_portal.create_group_preset
  default_portal.create_organization_preset
end
