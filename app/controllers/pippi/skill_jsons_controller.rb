class Pippi::SkillJsonsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  navi_view "pippi/main/navi"
  menu_view nil

  public

  def index
  end
end
