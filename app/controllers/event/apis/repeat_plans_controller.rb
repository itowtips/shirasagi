class Event::Apis::RepeatPlansController < ApplicationController
  include Cms::ApiFilter

  public
    def index
      #
    end

    def create
      dump params
    end
end
