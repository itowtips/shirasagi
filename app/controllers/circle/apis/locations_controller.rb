class Circle::Apis::LocationsController < ApplicationController
  include Cms::ApiFilter

  model Circle::Node::Location
end
