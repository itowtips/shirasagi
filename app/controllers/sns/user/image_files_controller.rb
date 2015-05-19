class Sns::User::ImageFilesController < ApplicationController
  include Sns::UserFilter
  include Sns::CrudFilter
  include Sns::FileFilter
  include SS::AjaxFilter

  model SS::File

  private
    def fix_params
      { cur_user: @cur_user }
    end

  public
    def show
      @image = Magick::Image.from_blob(@item.read).shift

      if params[:size].present?
        width  = params[:size][:width].to_i
        height = params[:size][:height].to_i
        @image = @image.resize(width, height)
        dump [width, height]
      end

      send_data @image.to_blob, type: @item.content_type, filename: @item.filename,
        disposition: :inline
    end

    def edit
      @image = Magick::Image.from_blob(@item.read).shift
      @query = "?" + { size: params[:size] }.to_query if params[:size].present?
    end

    def update
      @image = Magick::Image.from_blob(@item.read).shift
      width  = params[:size][:width].to_i
      height = params[:size][:height].to_i
      @image = @image.resize(width, height).to_blob

      file = Fs::UploadedFile.new(@item.basename)
      file.binmode
      file.write(@image)
      file.rewind
      file.original_filename = @item.basename
      file.content_type = ::Fs.content_type(@item.basename)

      @item.in_file = file
      if @item.save
        head :no_content
      else
        raise "500"
      end
    end
end
