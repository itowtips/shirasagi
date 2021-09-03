class Cms::Line::Template::Page < Cms::Line::Template::Base
  include Cms::Addon::Line::Template::Page

  field :title, type: String
  field :summary, type: String
  field :thumb_state, type: String, default: "none"
  permit_params :title, :summary, :thumb_state

  validates :title, presence: true, length: { maximum: 80 }
  validates :summary, presence: true, length: { maximum: 400 }
  validate :validate_page

  def type
    "page"
  end

  def balloon_html
    h = []

    if page.blank?
      h << '<div class="talk-balloon" style="color: red;">'
      h << "※ページが削除されています。<br>※メッセージは配信されません。"
      h << '</div>'
      return h.join
    end

    query = "?_=#{Time.zone.now.to_i}"
    h << '<div class="talk-balloon">'
    h << '<div class="message-type page">'
    if thumb_image_full_url
      h << "<div class=\"img-warp\"><img src=\"#{thumb_image_full_url}#{query}\"></div>"
    end
    h << "<div class=\"title\">#{title}</div>"
    h << "<div class=\"summary\">#{summary}</div>"
    h << "<div class=\"footer\"><a href=\"#{page.full_url}\">#{I18n.t("cms.visit_article")}</a></div>"
    h << '</div>'
    h << '</div>'
    h.join
  end

  def body
    raise "page deleted!" if page.blank?
    raise "page not published!" if !page.public?
    Cms::LineUtils.flex_carousel_template(title, page) do |item, opts|
      opts[:name] = title
      opts[:text] = summary
      opts[:image_url] = thumb_image_full_url
      opts[:action] = {
        type: "uri",
        label: I18n.t("cms.visit_article"),
        uri: item.full_url
      }
    end
  end

  def thumb_image_full_url
    return if page.blank?
    if thumb_state == "thumb_carousel"
      page.thumb.try(:full_url)
    elsif thumb_state == "body_carousel"
      page.try(:first_img_full_url)
    else
      nil
    end
  end

  def thumb_state_options
    I18n.t("cms.options.line_template_thumb_state").map { |k, v| [v, k] }
  end

  private

  def validate_page
    if page.blank?
      errors.add :page_id, :blank
      return
    end

    if thumb_state == "thumb_carousel" && page.thumb.blank?
      errors.add :thumb_state, ": ページにサムネイル画像が設定されていません。"
    end
  end
end
