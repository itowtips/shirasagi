module Gws::Portal::PortalModel
  extend ActiveSupport::Concern
  extend SS::Translation
  include Gws::Addon::Portal::NoticeSetting
  include Gws::Addon::Portal::MonitorSetting
  include Gws::Addon::Portal::LinkSetting

  included do
    attr_accessor :portal_type
    attr_accessor :cur_group
  end

  def my_portal?
    portal_type == :my_portal
  end

  def user_portal?
    portal_type == :user_portal
  end

  def group_portal?
    portal_type == :group_portal
  end

  def root_portal?
    portal_type == :root_portal
  end

  def portal_readable?(user, opts = {})
    return true if allowed?(:read, user, site: opts[:site] || site, strict: true)
    return true if respond_to?(:readable?) && readable?(user, site: opts[:site] || site)
    false
  end

  #def save_default_portlets(settings = [])
  #  default_portlets(settings).each do |item|
  #    user_ids = [@cur_user.id]
  #   user_ids << portal_user_id if try(:portal_user_id)
  #
  #    item.cur_user   = @cur_user
  #    item.cur_site   = @cur_site
  #    item.setting_id = id
  #    item.user_ids   = user_ids
  #    item.group_ids  = [portal_group_id] if try(:portal_group_id)
  #
  #    if !item.save
  #      Rails.logger.warn("#{__FILE__}:#{__LINE__} - " + item.errors.full_messages.join(' '))
  #    end
  #  end
  #end

  def reset_portal(preset_portal)
    synchronize_portal(preset_portal, reset: true)
  end

  def synchronize_portal(preset_portal, reset: false)
    self.portlets.destroy_all if reset

    managed_portlets = {}
    self.portlets.each do |portlet|
      preset_portlet = portlet.preset_portlet
      next unless preset_portlet
      managed_portlets[preset_portlet.id.to_s] = portlet
    end

    self.portal_notice_state = preset_portal.portal_notice_state
    self.portal_notice_browsed_state = preset_portal.portal_notice_browsed_state
    self.portal_monitor_state = preset_portal.portal_monitor_state
    self.portal_link_state = preset_portal.portal_link_state
    if !save
      Rails.logger.warn("#{__FILE__}:#{__LINE__} - " + errors.full_messages.join(' '))
    end

    preset_portlets = reset ? preset_portal.default_portlets : preset_portal.required_portlets
    preset_portlets.each do |preset_portlet|
      item = managed_portlets[preset_portlet.id.to_s] || self.portlets.new
      item.cur_user = self.user
      item.cur_site = self.site
      item.setting_id = self.id
      item.group_ids = self.group_ids
      item.readable_group_ids = self.group_ids
      item.user_ids = self.user_ids
      item.readable_setting_range = "public"

      item.initialize_by_preset(preset_portlet) if preset_portlet
      item.grid_data = preset_portlet.grid_data if item.new_record?

      if !item.save
        Rails.logger.warn("#{__FILE__}:#{__LINE__} - " + item.errors.full_messages.join(' '))
      end
    end
  end
end
