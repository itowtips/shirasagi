class Facility::SearchWithGeolocationsController < ApplicationController
  def index
    redirect_to facility_searches_path
  end
end
