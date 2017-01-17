module JobDb::ListHelper
  def public_path_for_company(node, company)
    "#{node.url}#{company.filename}/"
  end

  def public_url_for_company(node, company)
    "#{node.full_url}#{company.filename}/"
  end

  def render_page_list(&block)
    cur_item = @cur_part || @cur_node
    cur_item.cur_date = @cur_date

    h = []
    h << cur_item.upper_html.html_safe if cur_item.upper_html.present?
    if block_given?
      h << capture(&block)
    else
      @items.each do |item|
        if cur_item.loop_html.present?
          ih = cur_item.render_loop_html(item)
        else
          ih = []
          ih << '<article class="item-#{class} #{new} #{current}">'
          ih << '  <header>'
          ih << '    <time datetime="#{date.iso}">#{date.long}</time>'
          ih << '    <h2><a href="#{url}">#{index_name}</a></h2>'
          ih << '  </header>'
          ih << '</article>'
          ih = cur_item.render_loop_html(item, html: ih.join("\n"))
        end
        h << ih.gsub('#{current}', current_url?(public_path_for_company(@cur_node, item)).to_s)
      end
    end
    h << cur_item.lower_html.html_safe if cur_item.lower_html.present?

    h.join("\n").html_safe
  end
end
