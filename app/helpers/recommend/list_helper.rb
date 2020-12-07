module Recommend::ListHelper
  def render_content_list
    cur_item = @cur_part
    cur_item.cur_date = @cur_date

    h = []
    h << cur_item.upper_html.html_safe if cur_item.upper_html.present?

    if cur_item.exclude_paths.present?
      display_list = cur_item.exclude_paths.to_a
    else
      display_list = []
    end

    displayed = 0
    @items.each do |item|
      next if display_list.index(item.path)
      next if display_list.index(item.access_url)
      content = item.content
      next unless content
      next unless content.public?

      if @cur_site.inquiry_form.try(:filename) == content.filename
        display_list << item.access_url
      else
        display_list << item.path
      end
      displayed += 1
      if cur_item.loop_setting.present?
        ih = item.render_template(cur_item.loop_setting.html, self)
      elsif cur_item.loop_html.present?
        if @cur_site.inquiry_form.try(:filename) == content.filename
          uri = Addressable::URI.parse(item.access_url)
          query = Rack::Utils.parse_nested_query(uri.query)
          group = Cms::Group.where(id: query['group'].to_s).first
          html = cur_item.loop_html.gsub('#{url}', item.access_url)
          if group.present?
            if group.contact_group_name.present?
              group_name = group.contact_group_name + " " + content.name
            else
              group_name = group.section_name + " " + content.name
            end
            html = html.gsub('#{name}', group_name)
          end
        else
          html = cur_item.loop_html
        end
        ih = cur_item.render_loop_html(content, html: html)
      else
        ih = []
        ih << '<article class="item-#{class}">'
        ih << '  <header>'
        ih << '    <h2><a href="#{url}">#{name}</a></h2>'
        ih << '  </header>'
        ih << '</article>'
        ih = cur_item.render_loop_html(content, html: ih.join("\n"))
      end
      h << ih.gsub('#{current}', current_url?(content.url).to_s)
      break if displayed >= @limit
    end
    h << cur_item.lower_html.html_safe if cur_item.lower_html.present?

    h.join.html_safe
  end
end
