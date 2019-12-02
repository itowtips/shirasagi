class Translate::Agents::Tasks::NodesController < ApplicationController
  include Cms::PublicFilter::Node

  def generate
    return if !@site.translate_enabled?

    @task.log "# #{@site.name}"

    generate_root_pages unless @node

    nodes = Cms::Node.site(@site).and_public
    nodes = nodes.where(filename: /^#{::Regexp.escape(@node.filename)}(\/|$)/) if @node
    ids   = nodes.pluck(:id)

    ids.each_with_index do |id, idx|
      node = Cms::Node.site(@site).and_public.where(id: id).first
      next unless node
      next unless node.public?
      next unless node.public_node?

      Dir.glob([node.path + "/index.html", node.path + "/index.*.html"]).each do |path|
        @task.log "#{idx + 1} : #{node.url}"
        @site.translate_targets.each do |target|
          html = Fs.read(path)
          converter = Translate::Convertor.new(@site, @site.translate_source, target)
          converter.convert(html)
        end
      end
    end
  end

  def generate_root_pages
    pages = Cms::Page.site(@site).and_public.where(depth: 1)
    ids   = pages.pluck(:id)

    @task.log "# pages #{ids.size}"

    ids.each_with_index do |id, idx|
      @task.count
      page = Cms::Page.site(@site).and_public.where(depth: 1).where(id: id).first
      next unless page

      @site.translate_targets.each do |target|
        next if !Fs.exists?(page.path)
        @task.log "#{idx + 1} : #{page.url}"

        html = Fs.read(page.path)
        converter = Translate::Convertor.new(@site, @site.translate_source, target)
        converter.convert(html)
      end
    end
  end
end
