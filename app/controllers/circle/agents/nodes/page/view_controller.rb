module Circle::Agents::Nodes::Page
  class ViewController < ApplicationController
    include Cms::NodeFilter::View
    helper Cms::ListHelper

    public
      def image_pages
        Circle::Image.site(@cur_site).public.
          where(filename: /^#{@cur_node.filename}\//, depth: @cur_node.depth + 1).order_by(order: -1)
      end

      def index
        @summary_image = nil
        @images = []
        image_pages.each do |page|
          next if page.image.blank?

          if @summary_image
            @images.push page
          else
            @summary_image = page
          end
        end
      end
  end
end
