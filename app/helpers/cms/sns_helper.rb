module Cms::SnsHelper
  def show_line_post_confirm?
    return false if !@item.class.include?(Cms::Addon::LinePoster)

    site = @item.site
    item = (@item.respond_to?(:master) && @item.master) ? @item.master : @item

    return false if !site.line_token_enabled?
    return false if @item.line_auto_post != "active"
    return false if item.line_posted.present?
    true
  end

  def show_twitter_post_confirm?
    return false if !@item.class.include?(Cms::Addon::TwitterPoster)

    item = (@item.respond_to?(:master) && @item.master) ? @item.master : @item

    return false if !@item.use_twitter_post?
    return false if item.twitter_posted.present?
    true
  end

  def facebook_post_confirm?
    facebook_category = Category::Node::Base.find(3536) rescue nil
    return false if facebook_category.nil?
    @item.category_ids.include?(facebook_category.id)
  end

  def render_sns_post_confirm
    messages = []
    if show_line_post_confirm?
      messages << t("cms.confirm.line_post_enabled")
    end
    if show_twitter_post_confirm?
      messages << t("cms.confirm.twitter_post_enabled")
    end
    if facebook_post_confirm?
      messages << t("cms.confirm.facebook_post_enabled")
    end

    return "" if messages.blank?

    h = []
    h << "<div class=\"sns-post-confirm\">"
    h << "<h2>#{t("cms.confirm.when_publish")}</h2>"
    h << "<ul>"
    messages.each do |message|
      h << ("<li>" + message + "</li>")
    end
    h << "</div>"

    return h.join("\n")
  end
end
