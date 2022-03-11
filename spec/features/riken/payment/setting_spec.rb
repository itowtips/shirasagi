require 'spec_helper'

describe "gws_riken_payment_setting", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:user) { gws_user }
  let(:item) { create(:riken_payment_importer_setting) }
  let!(:category) { create(:gws_circular_category) }

  let(:show_path) { gws_riken_payment_setting_path site.id }
  let(:edit_path) { edit_gws_riken_payment_setting_path site.id }

  let(:api_url) { "https://riken.example.jp/workflows" }
  let(:request_title) { unique_id }
  let(:remand_title) { unique_id }

  let(:token_url) { "https://riken.example.jp/token" }
  let(:client_id) { unique_id }
  let(:in_private_key) { OpenSSL::PKey::RSA.generate(2048).to_s }
  let(:sub) { user.uid }
  let(:scope) { "edit_other_gws_circular_posts" }
  let(:aud) { "https://riken.example.jp/token" }

  context "with auth" do
    before { login_gws_user }

    it "#show" do
      expect(Riken::Payment::ImporterSetting.site(site).count).to eq 0
      visit show_path
      click_on I18n.t("ss.links.edit")

      within "form#item-form" do
        fill_in "item[api_url]", with: api_url
        fill_in "item[request_title]", with: request_title
        fill_in "item[remand_title]", with: remand_title
        click_on I18n.t("ss.apis.users.index")
      end
      wait_for_cbox do
        click_on user.long_name
      end
      within "form#item-form" do
        click_on I18n.t("gws.apis.categories.index")
      end
      wait_for_cbox do
        click_on category.name
      end
      within "form#item-form" do
        fill_in "item[token_url]", with: token_url
        fill_in "item[client_id]", with: client_id
        fill_in "item[in_private_key]", with: in_private_key
        fill_in "item[sub]", with: sub
        fill_in "item[scope]", with: scope
        fill_in "item[aud]", with: aud
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
      expect(Riken::Payment::ImporterSetting.site(site).count).to eq 1
    end

    it "#edit" do
      item
      expect(Riken::Payment::ImporterSetting.site(site).count).to eq 1
      visit edit_path
      within "form#item-form" do
        fill_in "item[request_title]", with: "modify"
        click_button I18n.t('ss.buttons.save')
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
      expect(page).to have_css("#addon-basic", text: "modify")
      expect(Riken::Payment::ImporterSetting.site(site).count).to eq 1
    end
  end
end
