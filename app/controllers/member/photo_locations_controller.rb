class Member::PhotosLocationsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Member::Node::PhotosLocation

  navi_view "cms/node/main/navi"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "member/photo_location" }
    end
end
