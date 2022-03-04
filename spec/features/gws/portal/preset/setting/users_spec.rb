require 'spec_helper'

describe "gws_portal_setting_groups", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:preset) { Gws::Portal::Preset.find_by(portal_type: "user") }
  let(:index_path) { gws_portal_preset_portlets_path site, preset }

  let(:portal_notice_state) { I18n.t("ss.options.state.hide") }
  let(:portal_notice_browsed_state) { I18n.t("gws/board.options.browsed_state.both") }
  let(:portal_monitor_state) { I18n.t("ss.options.state.hide") }
  let(:portal_link_state) { I18n.t("ss.options.state.hide") }

  before { create_default_portal }

  context "show layout and update setting" do
    before { login_gws_user }

    it do
      visit index_path

      click_on I18n.t('gws/portal.links.arrange_portlets')
      click_on I18n.t("ss.buttons.reset")
      expect(page).to have_css(".gws-portlets .portlet-model-schedule")

      click_on I18n.t("gws/portal.links.settings")
      expect(page).to have_css("#addon-basic", text: preset.name)

      click_on I18n.t("ss.links.edit")
      within "form#item-form" do
        select portal_notice_state, from: "item[portal_notice_state]"
        select portal_notice_browsed_state, from: "item[portal_notice_browsed_state]"
        select portal_monitor_state, from: "item[portal_monitor_state]"
        select portal_link_state, from: "item[portal_link_state]"
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      within "#addon-gws-agents-addons-portal-notice_setting" do
        expect(page).to have_css('.addon-body', text: portal_notice_state)
        expect(page).to have_css('.addon-body', text: portal_notice_browsed_state)
      end
      within "#addon-gws-agents-addons-portal-monitor_setting" do
        expect(page).to have_css('.addon-body', text: portal_monitor_state)
      end
      within "#addon-gws-agents-addons-portal-link_setting" do
        expect(page).to have_css('.addon-body', text: portal_link_state)
      end
    end
  end
end
