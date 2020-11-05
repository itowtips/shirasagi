class Cms::Agents::Nodes::SiteSearchController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  before_action :set_setting
  before_action :set_search_history

  model Cms::Elasticsearch::Searcher

  private

  def set_setting
    @setting ||= begin
      setting_model = Cms::Elasticsearch::Setting::Page
      setting_model.new(cur_site: @cur_site, cur_user: @cur_user)
    end
  end

  def set_search_history
    keyword = get_params[:keyword].to_s.strip.gsub(/　/, " ")
    return if keyword.blank?

    token = cookies["_ss_site_search"]
    query = { keyword: keyword }
    user_agent = request.user_agent

    if token && !Cms::SiteSearch::History::Log.site(@cur_site).where(token: token).first
      token = nil
    end

    Cms::SiteSearch::History::Log.site(@cur_site).where(token: token, query: query).destroy_all

    log = Cms::SiteSearch::History::Log.new(
      token: token, site: @cur_site, query: query,
      user_agent: user_agent, remote_addr: remote_addr
    )
    log.save

    @search_histories = Cms::SiteSearch::History::Log.site(@cur_site).
      where(token: log.token).limit(6).to_a

    cookies.permanent["_ss_site_search"] = log.token
  end

  def fix_params
    { setting: @setting }
  end

  def permit_fields
    [:keyword, :target]
  end

  def get_params
    if params[:s].present?
      params.require(:s).permit(permit_fields).merge(fix_params)
    else
      fix_params
    end
  end

  public

  def index
    @s = @item = @model.new(get_params)

    if @s.keyword.present?
      if @cur_site.elasticsearch_sites.present?
        @s.index = @cur_site.elasticsearch_sites.collect { |site| "s#{site.id}" }.join(",")
      end

      if params[:target] == 'outside'
        indexes = @cur_site.elasticsearch_indexes.presence || SS::Config.cms.elasticsearch['indexes']
        @s.index = [@s.index, indexes].flatten.join(",")
      end

      @s.field_name = %w(text_index content title)
      @s.from = (params[:page].to_i - 1) * @s.size if params[:page].present?
      @result = @s.search
    end
  end
end
