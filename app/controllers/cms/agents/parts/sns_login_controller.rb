class Cms::Agents::Parts::SnsLoginController < ApplicationController
  include Cms::PartFilter::View
  include Cms::PublicFilter::Agent
  include SS::AuthFilter

  public
    def index
      require "uri"

      @cur_user = get_user_by_session
      @ref = ::URI.join(@cur_site.full_url, @cur_path)
    end
end
