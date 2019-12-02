class Translate::Agents::Tasks::PagesController < ApplicationController
  include Cms::PublicFilter::Page

  def generate
    return if !@site.translate_enabled?

    @task.log "# #{@site.name}"

    pages = Cms::Page.site(@site).and_public
    pages = pages.node(@node) if @node
    ids   = pages.pluck(:id)
    @task.total_count = ids.size
    @task.log "# pages #{ids.size}"

    ids.each_with_index do |id, idx|
      @task.count
      page = Cms::Page.site(@site).and_public.where(id: id).first
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
