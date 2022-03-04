require 'spec_helper'

describe "gws_portal_presets", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }

  let(:index_path) { gws_portal_presets_path site }
  let(:new_path) { new_gws_portal_preset_path site }
  let(:show_path) { gws_portal_preset_path site, item }
  let(:edit_path) { edit_gws_portal_preset_path site, item }
  let(:delete_path) { delete_gws_portal_preset_path site, item }

  let(:name) { unique_id }
  let(:portal_type) { I18n.t("gws/portal.options.portal_type.user") }
  let(:order) { 10 }
  let(:item) { create(:gws_portal_preset, name: name, portal_type: "user", order: order) }

  context "basic crud" do
    before { login_gws_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path
    end

    it "#new" do
      visit new_path
      within "form#item-form" do
        fill_in "item[name]", with: name
        select portal_type, from: "item[portal_type]"
        fill_in "item[order]", with: order
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      expect(page).to have_css("#addon-basic", text: item.name)
      expect(page).to have_css("#addon-basic", text: portal_type)
      expect(page).to have_css("#addon-basic", text: order)
    end

    it "#show" do
      visit show_path
      expect(page).to have_css("#addon-basic", text: item.name)
      expect(page).to have_css("#addon-basic", text: portal_type)
      expect(page).to have_css("#addon-basic", text: order)
    end

    it "#edit" do
      visit edit_path
      within "form#item-form" do
        fill_in "item[name]", with: "modify"
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      expect(page).to have_css("#addon-basic", text: "modify")
      expect(page).to have_css("#addon-basic", text: portal_type)
      expect(page).to have_css("#addon-basic", text: order)
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
