class Cms::Line::Service::FacilitySearch < Cms::Line::Service
  include Cms::Addon::Line::Service::FacilitySearch

  def switch_messages
    contents = []
    categories.each_with_index do |category, idx|
      contents << {
        "type": "button",
        "action": {
          "type": "message",
          "label": category.name,
          "text": category.name
        },
      }
      if (idx + 1) != categories.size
        contents <<  { "type": "separator" }
      end
    end

    [
      {
        "type": "text",
        "text": "探したい施設を選んでください"
      },
      {
        "type": "flex",
        "altText": "this is a flex message",
        "contents": {
          "type": "bubble",
          "size": "kilo",
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": contents,
          },
          "styles": {
            "body": {
              "separator": true,
              "separatorColor": "#000000"
            }
          }
        }
      }
    ]
  end
end
