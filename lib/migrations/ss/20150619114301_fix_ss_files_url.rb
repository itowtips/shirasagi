class SS::Migration20150619114301
  def change
    file_ids = SS::File.pluck(:id)
    file_ids.each do |id|
      item = SS::File.find(id) rescue nil
      next if item.nil?
      #next if item.filename.ascii_only?
      item.save!

      item.reload
      item.set(name: item.basename) if item.name.blank?
    end

    Cms::Page.all.each { |item| replace_fs_urls(item) }
    Cms::Node.all.each { |item| replace_fs_urls(item) }
    Cms::Layout.all.each { |item| replace_fs_urls(item) }
    Cms::Part.all.each { |item| replace_fs_urls(item) }
  end

  def replace_fs_urls(item)
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
    html.gsub(%r{(="/fs/)(\d+)(/[^\/]+\.[\w\-.]+")}) do
      head = $1
      id   = $2
      tail = $3
      url  = SS::File.find(id.to_i).url rescue nil

      if url
        "=\"#{url}\""
      else
        "#{head}#{id.split("").join("/")}/_#{tail}"
      end
    end
  end
end
