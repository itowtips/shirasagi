class Fs::Agents::Nodes::ImageViewerController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  def index
    if params[:ref].present?
      @url = ::Addressable::URI.escape(params[:ref])
    end
  end
end
