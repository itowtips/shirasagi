require 'rmagick'

module Fs::FileFilter
  extend ActiveSupport::Concern

  private
    def send_thumb(data, opts = {})
      width  = opts.delete(:width).to_i
      height = opts.delete(:height).to_i

      width  = (width  > 0) ? width  : 120
      height = (height > 0) ? height : 90

      image = Magick::Image.from_blob(data).shift

if image.columns > width || image.rows > height
      image = image.resize_to_fit width, height
      raise "this"
      raise [width, height].to_s
else
      raise [width, height].to_s
end

      send_data image.to_blob, opts
    end
end
