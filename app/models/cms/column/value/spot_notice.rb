class Cms::Column::Value::SpotNotice < Cms::Column::Value::Base
  liquidize do
    export :value
    export :pages
    export :notices_url
  end

  def value
    "施設のお知らせが表示されます。"
  end

  def notices_url
    page = _parent
    return "" if page.blank?

    facility = page.facility
    site = page.site
    return "" if facility.blank? || site.blank?

    @_node_url ||= ::Tourism::Node::Notice.site(site).first.try(:url)
    return "" if @_node_url.blank?

    "#{@_node_url}f-#{facility.id}/"
  rescue => e
    Rails.logger.error("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ""
  end

  def pages
    page = _parent
    return [] if page.blank?

    facility = page.facility
    site = page.site
    return [] if facility.blank? || site.blank?

    ::Tourism::Notice.site(site).in(facility_id: facility.id).
      order_by({ :released => -1 }).
      limit(5).to_a
  rescue => e
    Rails.logger.error("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    []
  end

  def to_default_html
    ""
  end
end
