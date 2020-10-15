module Cms::Addon
  module LinePoster
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :line_auto_post, type: String, metadata: { branch: false }
      field :line_posted, type: DateTime, metadata: { branch: false }

      field :line_text_message, type: String, metadata: { branch: false }
      field :line_post_format, type: String, metadata: { branch: false }

      validates :line_text_message, length: { maximum: 400 } # 5000

      permit_params :line_auto_post, :line_text_message, :line_post_format

      after_save :post_line_bot
    end

    def line_auto_post_options
      %w(expired active).map { |v| [I18n.t("ss.options.state.#{v}"), v] }
    end

    def line_post_format_options
      %w(thumb_carousel body_carousel message_only_carousel).map { |v| [I18n.t("cms.options.line_post_format_options.#{v}"), v] }
    end

    def line_post_enabled?
      self.site = site || @cur_site
      return false if !site.line_token_enabled?
      return false if line_posted.present?
      return false if line_auto_post != "active"
      true
    end

    def line_client
      self.site = site || @cur_site
      Line::Bot::Client.new do |config|
        config.channel_secret = site.line_channel_secret
        config.channel_token = site.line_channel_access_token
      end
    end

    private

    def post_line_bot
      return unless public?
      return unless public_node?
      return if @posted_line_bot

      post_to_line if line_post_enabled?

      @posted_line_bot = true
    end

    def post_to_line
      self.site = site || @cur_site

      client = line_client

      messages = []

      if line_post_format == "thumb_carousel"

        messages << {
          "type": "template",
          "altText": "this is a carousel template",
          "template": {
            "type": "carousel",
            "columns": [
              {
                "thumbnailImageUrl": thumb.full_url,
                "imageBackgroundColor": "#FFFFFF",
                "title": name,
                "text": line_text_message,
                "actions": [
                  {
                    "type": "uri",
                    "label": "記事を見る",
                    "uri": full_url
                  }
                ],
              },
            ],
            # "imageAspectRatio": "rectangle",
            # "imageSize": "cover"
          }
        }

      elsif line_post_format == "body_carousel"

        file_urls = SS::Html.extract_img_srcs(html).map { |url| ::File.join(site.full_root_url, url) }
        if file_urls.present?
          columns = file_urls.map do |url|
            {
              "thumbnailImageUrl": url,
              "imageBackgroundColor": "#FFFFFF",
              "title": name,
              "text": line_text_message,
              "actions": [
                {
                  "type": "uri",
                  "label": "記事を見る",
                  "uri": full_url
                }
              ],
            }
          end

          messages << {
            "type": "template",
            "altText": "this is a carousel template",
            "template": {
              "type": "carousel",
              "columns": columns,
              # "imageAspectRatio": "rectangle",
              # "imageSize": "cover"
            }
          }
        end

      elsif line_post_format == "message_only_carousel"

        if line_text_message.present?
          messages << {
            "type": "template",
            "altText": "this is a carousel template",
            "template": {
            "type": "carousel",
              "columns": [
                {
                  "title": name,
                  "text": line_text_message,
                  "actions": [
                    {
                      "type": "uri",
                      "label": "記事を見る",
                      "uri": full_url
                    }
                  ],
                },
              ],
            }
          }
        end

      end

      # text message
      #if line_text_message.present?
      #  messages << {
      #    "type": "text",
      #    "text": line_text_message
      #  }
      #end

      # thumb
      #if thumb.present?
        #messages << {
        #  "type": "image",
        #  "originalContentUrl": thumb.full_url,
        #  "previewImageUrl": thumb.full_url,
        #}
      #end

      raise "messages blank" if messages.blank?

      res = client.broadcast(messages)

      dump(messages)
      dump(res)
      dump(res.body)

      self.set(line_posted: Time.zone.now)
    rescue => e
      Rails.logger.fatal("post_to_line failed: #{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ensure
      #
    end

    def delete_sns
      return if @deleted_sns

      if sns_auto_delete_enabled?
        delete_sns_from_twitter
      end

      @deleted_sns = true
    end

    def delete_sns_from_twitter
      return if twitter_posted.blank?

      client = connect_twitter
      twitter_posted.each do |posted|
        post_id = posted[:twitter_post_id]
        client.destroy_status(post_id) rescue nil
      end
      self.unset(:twitter_post_id, :twitter_user_id, :twitter_posted, :twitter_post_error) rescue nil
    rescue => e
      Rails.logger.fatal("delete_sns_from_twitter failed: #{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
      self.set(twitter_post_error: "#{e.class} (#{e.message})")
    end
  end
end
