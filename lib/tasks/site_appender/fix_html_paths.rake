namespace :site_appender do
  task :fix_html_paths => :environment do
    #puts "Please input inner_site_name: inner=[inner_site_name]" or exit if ENV['inner'].blank?
    #@site = SS::Site.where(host: ENV['inner']).first

    def replace_fs_urls(item)
      puts item.name
      if item.respond_to?(:html) && item.html.present?
        item.set(html: gsub_urls(item.html))
      end

      if item.respond_to?(:upper_html) && item.upper_html.present?
        item.set(upper_html: gsub_urls(item.upper_html))
      end

      if item.respond_to?(:loop_html) && item.loop_html.present?
        item.set(loop_html: gsub_urls(item.loop_html))
      end

      if item.respond_to?(:lower_html) && item.lower_html.present?
        item.set(lower_html: gsub_urls(item.lower_html))
      end
    end

    def gsub_urls(html)
      html.gsub(%r{(="/fs/)(.+?)(/_/)([^\/]+\.[\w\-.]+")}) do |path|
        head = $1
        id   = $2.delete("/").to_i
        tail = $4
        url  = SiteAppender::Inner::SS::File.where(_old_id: id).first.url rescue nil

        if url
          "=\"#{url}\""
        else
          puts " not found #{path}"
          path
        end
      end
    end

    puts "## fix html paths"
    puts ""

    SiteAppender::Inner::Cms::Page.all.each_with_index do |item, idx|
      item = item.becomes_with_inner_id
      replace_fs_urls(item)
    end
    SiteAppender::Inner::Cms::Node.all.each_with_index do |item, idx|
      item = item.becomes_with_inner_id
      replace_fs_urls(item)
    end
    SiteAppender::Inner::Cms::Layout.all.each_with_index do |item, idx|
      item = item.becomes_with_inner_id
      replace_fs_urls(item)
    end
    SiteAppender::Inner::Cms::Part.all.each_with_index do |item, idx|
      item = item.becomes_with_inner_id
      replace_fs_urls(item)
    end
  end
end
