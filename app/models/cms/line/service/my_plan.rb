class Cms::Line::Service::MyPlan < Cms::Line::Service::Base
  include Cms::Addon::Line::Service::PageList

  def flex_carousel_template(title, items)
    items = [items] if !items.is_a?(Array)

    contents = items.map do |item|
      opts = OpenStruct.new
      yield(item, opts)

      image = opts[:image]
      image_url = opts[:image_url]
      name = opts[:name].to_s
      text = opts[:text].to_s
      action = opts[:action]

      content = { type: "bubble", size: "kilo" }

      if image
        content[:hero] = {
          type: "image",
          url: image.full_url,
          size: "full",
          aspectRatio: "20:13",
          aspectMode: "cover"
        }
      elsif image_url
        content[:hero] = {
          type: "image",
          url: image_url,
          size: "full",
          aspectRatio: "20:13",
          aspectMode: "cover"
        }
      end

      content[:body] = {
          type: "box",
          layout: "vertical",
          contents: []
      }

      # name
      content[:body][:contents] << {
          type: "text",
          text: name,
          wrap: true,
          weight: "bold",
          margin: "none"
      }

      # text
      text.split("\n").each_with_index do |line, idx|
        content[:body][:contents] << {
            type: "text",
            text: line,
            wrap: true,
            size: "sm",
            margin: (idx == 0) ? "md" : "none"
        }
      end

      # action
      if action
        content[:footer] = {
            type: "box",
            layout: "vertical",
            contents: [
                {
                    type: "button",
                    action: action,
                    style: "secondary",
                    margin: "none"
                }
            ]
        }
        content[:styles] = {
            footer: { separator: true }
        }
      end

      content
    end

    {
        type: "flex",
        altText: title,
        contents: {
            type: "carousel",
            contents: contents
        }
    }
  end

  def switch_messages
    date = Time.zone.now.change(hour: 0, min: 0, sec: 0)
    items = Cms::Page.public_list(site: site, parent: self).in(event_dates: date).to_a
    items = items.sort_by { |item| item.event_dates.size }
    items = items.take(10)

    if items.present?
      template = flex_carousel_template("今日の予定", items) do |item, opts|
        image_url = nil
        image_url = no_image.full_url if no_image

        if item.thumb
          image_url = item.thumb.full_url
        else
          html = item.form ? item.render_html : item.html
          src = SS::Html.extract_img_src(html.to_s, site.full_root_url)
          image_url = ::File.join(site.full_root_url, src) if src.present? && src.start_with?('/')
        end

        summary = []
        dates = item.get_event_dates.select { |dates| dates.include?(date) }.first
        if dates.present?
          dates = (dates.size == 1) ? [dates.first] : [dates.first, dates.last]
          dates = dates.map { |d| I18n.l(d.to_date, format: :long) }.join(I18n.t("event.date_range_delimiter"))
          summary << "日時：#{dates}"
        end

        column_value = item.column_values.where(name: "内容").first
        if column_value
          value = column_value.value.to_s.gsub(/\n/, " ").truncate(60)
          summary << "内容：#{value}"
        end
        summary = summary.join("\n")

        opts[:name] = item.name
        opts[:text] = summary
        opts[:image_url] = image_url if image_url.present?
        opts[:action] = {
          "type": "uri",
          "label": "ページを見る",
          "uri": item.full_url
        }
      end
      [
        {
          type: "text",
          text: "以下のイベントが本日開催予定です。"
        },
        template,
      ]
    else
      [
        {
          type: "text",
          text: "今日の予定はありませんでした。"
        }
      ]
    end
  end
end
