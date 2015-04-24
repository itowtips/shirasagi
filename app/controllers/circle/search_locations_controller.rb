class Circle::SearchLocationsController < ApplicationController
  include Cms::SearchFilter

  model Circle::Node::Location
end
