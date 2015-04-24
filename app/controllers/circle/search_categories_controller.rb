class Circle::SearchCategoriesController < ApplicationController
  include Cms::SearchFilter

  model Circle::Node::Category
end
