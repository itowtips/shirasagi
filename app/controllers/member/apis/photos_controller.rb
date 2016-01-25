class Member::Apis::PhotosController < ApplicationController
  include Cms::ApiFilter

  model Member::Photo

  layout "ss/ajax"

  public
    def select
      set_item
      render file: :select, layout: !request.xhr?
    end
end
