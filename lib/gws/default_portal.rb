class Gws::DefaultPortal
  def initialize(site)
    @site = site
    @user_portlet_conf ||= begin
      conf = SS.config.gws['portal']['user_portlets']
      conf.index_by { |data| data["model"] }
    end
    @group_portlet_conf ||= begin
      conf = SS.config.gws['portal']['group_portlets']
      conf.index_by { |data| data["model"] }
    end
    @organization_portlet_conf ||= begin
      conf = SS.config.gws['portal']['organization_portlets']
      conf.index_by { |data| data["model"] }
    end
  end

  def portlet_models(portal_type)
    case portal_type.to_s
    when "user"
      Gws::Portal::UserSetting.new.portlet_models
    when "group", "organization"
      Gws::Portal::GroupSetting.new.portlet_models
    end
  end

  def portlet_conf(portal_type, model)
    data = {}
    case portal_type.to_s
    when "user"
      conf = @user_portlet_conf[model.to_s]
    when "group"
      conf = @group_portlet_conf[model.to_s]
    when "organization"
      conf = @organization_portlet_conf[model.to_s]
    end
    return data unless conf

    # basic conf
    data[:show_default] = "show"
    data[:name] = conf['name'] if conf['name'].present?
    data[:grid_data] = conf['grid'].symbolize_keys if conf['grid'].present?

    # extra conf
    if conf['schedule_member_mode'].present?
      data[:schedule_member_mode] = conf['schedule_member_mode']
    end
    if conf['reminder_filter'].present?
      data[:reminder_filter] = conf['reminder_filter']
    end
    if conf['category_id'].present?
      data["#{model}_category_ids"] = conf['category_id']
    end
    data
  end

  def create_preset(portal_type)
    name = I18n.t("gws/portal.#{portal_type}_portal_setting")
    #puts name

    preset = Gws::Portal::Preset.find_or_create_by(site_id: @site.id, name: name, portal_type: portal_type)
    portal = preset.portal_setting
    portal.portlets.destroy_all

    models = portlet_models(portal_type)
    models.each do |model|
      portlet_model = model[:type]
      name = I18n.t("gws/portal.portlets.#{portlet_model}.name")
      text = I18n.t("gws/portal.portlets.#{portlet_model}.text")
      opts = {
        cur_site: @site,
        setting: portal,
        portlet_model: portlet_model,
        name: name,
        description: text,
        managed: "unmanaged",
        show_default: "hide"
      }
      opts.merge!(portlet_conf(portal_type, portlet_model))
      item = Gws::Portal::PresetPortlet.new(opts)
      #puts "- #{item.name} #{item.label(:show_default)}"
      item.save!
    end
  end

  def create_user_preset
    create_preset(:user)
  end

  def create_group_preset
    create_preset(:group)
  end

  def create_organization_preset
    create_preset(:organization)
  end
end
