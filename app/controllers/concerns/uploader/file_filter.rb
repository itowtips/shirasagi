module Uploader::FileFilter
  extend ActiveSupport::Concern
  include Cms::BaseFilter
  include Cms::CrudFilter

  included do
    before_action :create_folder
    before_action :set_item
  end

  private
    def create_folder
      return if @model.file(@cur_node.path)
      cur_folder = @model.new path: @cur_node.path, is_dir: true
      raise "404" unless cur_folder.save
    end

    def set_item
      return if params[:filename].blank?

      filename = ::CGI.unescape params[:filename]
      raise "404" unless filename =~ /^#{@cur_node.filename}\//
      @item = @model.file "#{@cur_node.site.path}/#{filename}"
      @item.read if @item && @item.text?

      @parent = @item.parent
      @parent = nil if @parent.path == @cur_node.path
    end

    def set_items(path)
      @items = @model.find(path).sort_by
      dirs  = @items.select{ |item| item.directory?  }.sort_by { |item| item.name.capitalize }
      files = @items.select{ |item| !item.directory? }.sort_by { |item| item.name.capitalize }
      @items =  dirs + files
    end

  public
    def edit
      raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)
      raise "404" unless @item
    end

    def show
      raise "403" unless @cur_node.allowed?(:read, @cur_user, site: @cur_site)
      raise "404" unless @item
    end

    def new
      raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)
    end

    def create
      params[:item][:files].each do |file|
        path = ::File.join(@cur_site.path, @item.filename, file.original_filename)
        item = @model.new(path: path, binary: file.read)

        if !item.save
          item.errors.each do |n, e|
            @item.errors.add item.name, e
          end
        end
      end

      render_create @item.errors.empty?, location: { action: :index }
    end

    def new_directory
      raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)
    end

    def create_directory
      path = "#{@item.path}/#{params[:item][:directory]}"
      item = @model.new path: path,  is_dir: true

      if item.save
        render_create true, location: "#{uploader_files_path}/#{@item.filename}"
      else
        item.errors.each do |n, e|
          @item.errors.add :path, e
        end
        @directory = params[:item][:directory]
        render :new_directory
      end
    end

    def update
      raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)

      filename = params[:item][:filename]
      text = params[:item][:text]

      if !@item.directory?
        if text
          @item.text = text
        else
          @item.read
        end
      end

      @item.filename = filename if filename && filename =~ /^#{@cur_node.filename}/

      if @item.save
        render_update true, location: "#{uploader_files_path}/#{@item.filename}?do=edit"
      else
        @item.path = @item.saved_path
        render file: :edit
      end
    end

    def destroy
      raise "403" unless @cur_node.allowed?(:edit, @cur_user, site: @cur_site)

      dirname = @item.dirname
      @item.destroy
      render_destroy true, location: "#{uploader_files_path}/#{dirname}"
    end
end
