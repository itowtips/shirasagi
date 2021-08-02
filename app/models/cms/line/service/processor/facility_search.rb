class Cms::Line::Service::Processor::FacilitySearch < Cms::Line::Service::Processor::Base

  def carousel_template(title, columns)
    columns = [columns] if !columns.is_a?(Array)
    {
      "type": "template",
      "altText": title,
      "template": {
        "type": "carousel",
        "columns": columns,
        "imageAspectRatio": "rectangle",
        "imageSize": "cover"
      }
    }
  end

  def call
    events.each do |event|
      if event["type"] == "message" && event["message"]["type"] == "text"
        reply_text_message(event)
      elsif event["type"] == "message" && event["message"]["type"] == "location"
        reply_location(event)
      end
    end
  end

  def reply_text_message(event)
    text = event["message"]["text"]

    service.categories.each do |category|
      if category.name == text
        reply_category(event, category)
        break
      elsif "#{category.name}を探す" == text
        reply_search(event, category)
        break
      end
    end
  end

  def reply_category(event, category)
    column = {
      "title": category.name,
      "text": category.summary,
      "actions": [
        {
          "type": "message",
          "label": "#{category.name}を探す",
          "text": "#{category.name}を探す"
        }
      ]
    }
    if category.image
      column["thumbnailImageUrl"] = category.image.full_url
      column["imageBackgroundColor"] = "#FFFFFF"
    end
    client.reply_message(event["replyToken"], carousel_template(category.name, column))
  end

  def reply_search(event, category)
    event_session.set_data(:category, category.id)
    text1 = "1. マップ上の赤いピンで位置を指定します。"
    text2 = "2. 赤いピン上部の吹き出しの内の「位置情報を送信」をタップします。"
    #column = {
    #  "title": "位置情報の送信",
    #  "text": text,
    #  "actions": [
    #    {
    #      "type": "uri",
    #      "label": "位置情報を送信する",
    #      "uri": "https://line.me/R/nv/location/"
    #    }
    #  ]
    #}
    messages = {
      "type": "flex",
      "altText": "this is a flex message",
      "contents": {
        "type": "bubble",
        "size": "kilo",
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "位置情報の送信"
            },
            {
              "type": "text",
              "text": text1,
              "wrap": true,
              "size": "xs"
            },
            {
              "type": "text",
              "text": text2,
              "wrap": true,
              "size": "xs"
            },
            {
              "type": "button",
              "action": {
                "type": "uri",
                "label": "位置情報を送信する",
                "uri": "https://line.me/R/nv/location/"
              }
            }
          ]
        }
      }
    }

    client.reply_message(event["replyToken"], messages)
  end

  def reply_location(event)
    lat = event["message"]["latitude"]
    lon = event["message"]["longitude"]
    loc = [lon, lat]

    category_ids = service.categories.select do |item|
      item.id == event_session.get_data(:category)
    end.first.try(:category_ids)
    facility_maps = Facility::Map.site(site).to_a

    points = []
    facility_maps.each do |item|
      facility = item.parent.becomes_with_route
      next if !facility.public?
      next if (facility.category_ids & category_ids).blank?

      item.map_points.each do |point|
        point = OpenStruct.new(point)
        point[:facility] = facility
        point[:distance] = ::Geocoder::Calculations.distance_between(
          loc.reverse, point.loc.reverse, units: :km
        )
        points << point
      end
    end
    points = points.sort_by(&:distance)

    columns = points.take(10).map do |point|
      {
        "title": point.facility.name,
        "text": "#{point.facility.address}\n #{point.distance}",
        "actions": [
          {
            "type": "uri",
            "label": I18n.t("chat.line_bot.service.details"),
            "uri": point.facility.full_url
          }
        ]
      }
    end

    if columns.blank?
      client.reply_message(event['replyToken'], {
        "type": "text",
        "text": "施設が見つかりませんでした。"
      })
    else
      messages = [
        {
          "type": "text",
          "text": "以下の施設が見つかりました（#{points.size}）"
        },
        carousel_template("施設検索結果", columns)
      ]
      client.reply_message(event["replyToken"], messages)
    end
  end
end
