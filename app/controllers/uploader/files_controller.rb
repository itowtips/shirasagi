class Uploader::FilesController < ApplicationController
  include Uploader::FileFilter

  model Uploader::File

  navi_view "uploader/main/navi"

  public
    def index
      raise "403" unless @cur_node.allowed?(:read, @cur_user, site: @cur_site)
      set_items(@cur_node.path)
    end

    def create
      @item = @cur_node
      super
    end
end
