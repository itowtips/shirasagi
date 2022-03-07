require 'spec_helper'

describe "gws_portal_preset_portlets", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let!(:preset) { create(:gws_portal_preset, portal_type: "user") }

  let(:index_path) { gws_portal_preset_portlets_path site, preset }
  let(:new_path) { new_gws_portal_preset_portlet_path site, preset }
  let(:show_path) { gws_portal_preset_portlet_path site, preset, item }
  let(:edit_path) { edit_gws_portal_preset_portlet_path site, preset, item }
  let(:delete_path) { delete_gws_portal_preset_portlet_path site, preset, item }

  let(:name) { unique_id }
  let(:managed) { I18n.t("gws/portal.options.managed.managed") }
  let(:required) { I18n.t('ss.options.state.required') }
  let(:show_default) { I18n.t('ss.options.state.show') }
  let(:description) { unique_id }
  let(:order) { 10 }

  let(:item) do
    create(:gws_portal_preset_portlet,
      name: name,
      portlet_model: "free",
      setting: preset.portal_setting,
      managed: "managed",
      required: "required",
      show_default: "show",
      description: description,
      order: order)
  end

  context "basic crud" do
    before { login_gws_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path
    end

    it "#new" do
      visit new_path
      within ".main-box" do
        expect(page).to have_link I18n.t("gws/portal.portlets.free.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.links.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.reminder.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.schedule.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.todo.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.bookmark.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.report.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.workflow.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.circular.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.monitor.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.board.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.faq.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.qna.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.share.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.attendance.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.notice.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.presence.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.survey.name")
        expect(page).to have_link I18n.t("gws/portal.portlets.ad.name")
        click_on I18n.t("gws/portal.portlets.free.name")
      end
      within "form#item-form" do
        fill_in "item[name]", with: name
        select managed, from: "item[managed]"
        select required, from: "item[required]"
        select show_default, from: "item[show_default]"
        fill_in "item[description]", with: description
        fill_in "item[order]", with: order
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      expect(page).to have_css("#addon-basic", text: name)
      within "#addon-gws-agents-addons-portal-portlet-preset_setting" do
        expect(page).to have_css(".addon-body", text: managed)
        expect(page).to have_css(".addon-body", text: required)
        expect(page).to have_css(".addon-body", text: show_default)
        expect(page).to have_css(".addon-body", text: description)
        expect(page).to have_css(".addon-body", text: order)
      end
    end

    it "#show" do
      visit show_path
      expect(page).to have_css("#addon-basic", text: name)
      within "#addon-gws-agents-addons-portal-portlet-preset_setting" do
        expect(page).to have_css(".addon-body", text: managed)
        expect(page).to have_css(".addon-body", text: required)
        expect(page).to have_css(".addon-body", text: show_default)
        expect(page).to have_css(".addon-body", text: description)
        expect(page).to have_css(".addon-body", text: order)
      end
    end

    it "#edit" do
      visit edit_path
      within "form#item-form" do
        fill_in "item[name]", with: "modify"
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      expect(page).to have_css("#addon-basic", text: "modify")
      within "#addon-gws-agents-addons-portal-portlet-preset_setting" do
        expect(page).to have_css(".addon-body", text: managed)
        expect(page).to have_css(".addon-body", text: required)
        expect(page).to have_css(".addon-body", text: show_default)
        expect(page).to have_css(".addon-body", text: description)
        expect(page).to have_css(".addon-body", text: order)
      end
    end

    it "#delete" do
      visit delete_path
      within "form" do
        click_button I18n.t('ss.buttons.delete')
      end
      expect(current_path).to eq index_path
    end
  end
end
