class Cms::Apis::NodesController < ApplicationController
  include Cms::ApiFilter

  model Cms::Node
end
