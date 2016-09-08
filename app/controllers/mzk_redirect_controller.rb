class MzkRedirectController < ApplicationController
  include Sns::BaseFilter

  def index
    after_path = params[:after_path]
    redirect_to "/.s1/#{after_path}"
  end
end
