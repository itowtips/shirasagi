class Uploader::File::FilesController < ApplicationController
  include Uploader::FileFilter

  model Uploader::File

  navi_view "uploader/main/navi"

  public
    def index
      raise "403" unless @cur_node.allowed?(:read, @cur_user, site: @cur_site)
      raise "404" unless @item && @item.directory?
      set_items(@item.path)
    end
end
