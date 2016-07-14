module Cms::MenuHelper
  def render_menu_list
    cur_item = @cur_part
    cur_item.cur_date = @cur_date

    h = []

    if cur_item.upper_html.present?
      h << cur_item.upper_html.html_safe
    else
      h << '<ul>'
    end

    @items.each do |item|
      if cur_item.loop_html.present?
        ih = cur_item.render_loop_html(item)
      else
        ih = []
        ih << '<li class="item-#{class} #{current}">'
        ih << '  <a href="#{url}">#{name}</a>'
        ih << '</li>'
        ih = cur_item.render_loop_html(item, html: ih.join("\n"))
      end
      h << ih.gsub('#{current}', current_url?(item.url).to_s)
    end

    if cur_item.lower_html.present?
      h << cur_item.lower_html.html_safe
    else
      h << '</ul>'
    end

    h.join.html_safe
  end
end
