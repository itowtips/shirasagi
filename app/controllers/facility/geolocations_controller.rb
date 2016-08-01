class Facility::GeolocationsController < ApplicationController
  def index
    redirect_to facility_searches_path
  end
end
