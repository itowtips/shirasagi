module Map::MapHelper
  def render_marker_info(item)
    h = []

    h << %(<div class="maker-info" data-id="#{item.id}">)
    h << %(<p class="name">#{item.name}</p>)
    h << %(<p class="address">#{item.address}</p>)
    h << %(<p class="show"><a href="#{item.url}">#{item.name}</a></p>)
    h << %(</div>)

    h.join("\n")
  end

  def render_map_sidebar(item)
    h = []

    h << %(<div class="column" data-id="#{item.id}">)
    h << %(<p><a href="#{item.url}">#{item.name}</a></p>)
    h << %(<p>#{item.address}</p>)
    h << %(<p><a href="#" class="click-marker">#{I18n.t("facility.sidebar.click_marker")}</a></p>)
    h << %(</div>)

    h.join("\n")
  end
end
