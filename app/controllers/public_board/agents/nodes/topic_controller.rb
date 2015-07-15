class PublicBoard::Agents::Nodes::TopicController < ApplicationController
  include Cms::NodeFilter::View

  model PublicBoard::Post

  before_action :set_topic

  private
    def permit_fields
      @model.permitted_fields
    end

    def fix_params
      { cur_site: @cur_site, parent: @cur_topic }
    end

    def get_params
      params.require(:item).permit(permit_fields).merge(fix_params)
    end

    def set_topic
      return unless params[:tid]
      @cur_topic = PublicBoard::Topic.site(@cur_site).find params[:tid]
      @cur_node.name = @cur_topic.name
    end

  public
    def index
      @items = PublicBoard::Topic.site(@cur_site)
    end

    def show
      @items = PublicBoard::Comment.site(@cur_site).where(parent_id: @cur_topic.id)
    end

    def new
      @item = @model.new
    end

    def create
      @item = @model.new get_params

      if @item.valid_with_captcha? && @item.save
        redirect_to "#{@cur_node.url}#{@cur_topic.id}/", notice: t("views.notice.saved")
      else
        render :new
      end
    end
end
