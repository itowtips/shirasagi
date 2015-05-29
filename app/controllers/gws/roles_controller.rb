class Gws::RolesController < ApplicationController
  include Gws::BaseFilter
  include SS::CrudFilter
  model Gws::Role
end
