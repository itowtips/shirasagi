class Cms::Line::Service::MyPlan < Cms::Line::Service::Base
  include Cms::Addon::Line::Service::PageList

  def switch_messages
    date = Time.zone.now.change(hour: 0, min: 0, sec: 0)
    items = Cms::Page.public_list(site: site, parent: self).in(event_dates: date).to_a
    items = items.sort_by { |item| item.event_dates.size }
    items = items.take(10)

    if items.present?
      template = Cms::LineUtils.flex_carousel_template("今日の予定", items) do |item, opts|
        image_url = no_image.try(:full_url)
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
