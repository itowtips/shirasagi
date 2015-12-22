module Facility
  class Initializer
    Cms::Node.plugin "facility/node"
    Cms::Node.plugin "facility/page"
    Cms::Node.plugin "facility/category"
    Cms::Node.plugin "facility/service"
    Cms::Node.plugin "facility/location"
    Cms::Node.plugin "facility/search"

    #Cms::Role.permission :read_other_facility_nodes
    Cms::Role.permission :read_other_facility_pages
    #Cms::Role.permission :read_private_facility_nodes
    Cms::Role.permission :read_private_facility_pages

    #Cms::Role.permission :edit_other_facility_nodes
    Cms::Role.permission :edit_other_facility_pages
    #Cms::Role.permission :edit_private_facility_nodes
    Cms::Role.permission :edit_private_facility_pages

    #Cms::Role.permission :delete_other_facility_nodes
    Cms::Role.permission :delete_other_facility_pages
    #Cms::Role.permission :delete_private_facility_nodes
    Cms::Role.permission :delete_private_facility_pages

    Cms::Role.permission :release_other_facility_pages
    Cms::Role.permission :release_private_facility_pages

    Cms::Role.permission :approve_other_facility_pages
    Cms::Role.permission :approve_private_facility_pages
  end
end
