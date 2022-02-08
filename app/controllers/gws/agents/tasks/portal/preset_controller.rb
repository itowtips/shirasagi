class Gws::Agents::Tasks::Portal::PresetController < ApplicationController

  def each_user_portals
    users = Gws::User.site(@site).order_by_title(@site).to_a
    users.each do |user|
      portal = user.find_portal_setting(cur_user: user, cur_site: @site)
      portal.save if portal.new_record?
      preset = user.find_portal_preset(cur_user: user, cur_site: @site)

      if preset
        @task.log "#{user.name} - #{preset.name}"
        yield(portal, preset)
      else
        @task.log "#{user.name} - #{I18n.t("gws/portal.messages.task.not_found_preset")}"
      end
    end
  end

  def each_group_portals
    groups = Gws::Group.site(@site).to_a
    groups.each do |group|
      portal = group.find_portal_setting(cur_site: @site)
      portal.save if portal.new_record?
      preset = group.find_portal_preset(cur_site: @site)

      if preset
        @task.log "#{group.name} - #{preset.name}"
        yield(portal, preset)
      else
        @task.log "#{group.name} - #{I18n.t("gws/portal.messages.task.not_found_preset")}"
      end
    end
  end

  def sync
    @task.log "\# #{@site.name}"
    @task.log "\#\# #{I18n.t("gws/portal.messages.task.sync_user_started")}"
    each_user_portals do |portal, preset|
      portal.synchronize_portal(preset.portal_setting)
    end
    @task.log ""
    @task.log "\#\# #{I18n.t("gws/portal.messages.task.sync_group_started")}"
    each_group_portals do |portal, preset|
      portal.synchronize_portal(preset.portal_setting)
    end
    head :ok
  end

  def reset
    @task.log "\# #{@site.name}"
    @task.log "\#\# #{I18n.t("gws/portal.messages.task.reset_user_started")}"
    each_user_portals do |portal, preset|
      portal.reset_portal(preset.portal_setting)
    end
    @task.log ""
    @task.log "\#\# #{I18n.t("gws/portal.messages.task.reset_group_started")}"
    each_group_portals do |portal, preset|
      portal.reset_portal(preset.portal_setting)
    end
    head :ok
  end
end
