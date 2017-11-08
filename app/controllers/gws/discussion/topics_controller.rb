class Gws::Discussion::TopicsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Discussion::Topic

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_crumbs
    @crumbs << [I18n.t('modules.gws/discussion'), gws_discussion_topics_path]
  end

  public

  def index
    @items = @model.site(@cur_site).topic.
      allow(:read, @cur_user, site: @cur_site).
      search(params[:s]).
      page(params[:page]).per(50)
  end

  def create
    @item = @model.new get_params
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    result = @item.save

    if result
      @main_post = Gws::Discussion::Post.new fix_params
      @main_post.topic_id = @item.id
      @main_post.parent_id = @item.id
      @main_post.main_topic_id = @item.id
      @main_post.name = "メインスレッド"
      #@main_post.file_ids = @item.files.map do |file|
      #  f = SS::File.new(model: @main_post.model_name.i18n_key)
      #  f.in_file = Fs::UploadedFile.create_from_file(file.path)
      #  f.save!
      #  f.id
      #end
      @main_post.save!
    end

    render_create result
  end

=begin
  def update
    @item.attributes = get_params
    @item.in_updated = params[:_updated] if @item.respond_to?(:in_updated)
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    result = @item.update

    @main_post = @item.main_post
    if result && @main_post
      @main_post.attributes = get_params
      @main_post.in_updated = params[:_updated] if @item.respond_to?(:in_updated)
      @main_post.topic_id = @item.id
      @main_post.parent_id = @item.id
      @main_post.main_topic_id = @item.id
      @main_post.name = "メインスレッド"
      @main_post.files.each { |file| file.destroy }
      @main_post.file_ids = @item.files.map do |file|
        f = SS::File.new(model: @main_post.model_name.i18n_key)
        f.in_file = Fs::UploadedFile.create_from_file(file.path)
        f.save!
        f.id
      end
      @main_post.save!
    end
    render_update result
  end
=end
end
