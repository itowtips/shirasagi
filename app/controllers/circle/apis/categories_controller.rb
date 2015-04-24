class Circle::Apis::CategoriesController < ApplicationController
  include Cms::ApiFilter

  model Circle::Node::Category
end
