require 'spec_helper'

describe "gws_riken_payment_workflow_samples", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:item) { create(:riken_payment_workflow_sample) }

  let(:name) { "sample" }
  let(:workflow_id) { "123456" }
  let(:status) { "0" }
  let(:url) { "https://proxyapp.intra.riken.jp/" }
  let(:update_time) { "99991231235959" }
  let(:delegation_start_date) { "20220401" }
  let(:delegation_end_date) { "20230331" }
  let(:proxy_id) { "123456" }
  let(:proxy_name) { "理研 課員" }
  let(:proxy_lab) { "本部総務部総務課" }
  let(:proxy_position) { "課・室員" }
  let(:authorizer_id) { "789012" }
  let(:authorizer_name) { "理研 課長" }
  let(:authorizer_lab) { "本部総務部総務課" }
  let(:authorizer_position) { "課長" }
  let(:delegation_1) { "1" }
  let(:delegation_2) { "1" }
  let(:delegation_3) { "1" }
  let(:note) { "メモ" }
  let(:create_time) { "99991231235959" }
  let(:create_id) { "123456" }
  let(:create_name) { "理研 課員" }
  let(:create_lab) { "本部総務部総務課" }
  let(:create_position) { "課・室員" }

  let(:index_path) { gws_riken_payment_workflow_samples_path site.id }
  let(:new_path) { new_gws_riken_payment_workflow_sample_path site.id }
  let(:show_path) { gws_riken_payment_workflow_sample_path site.id, item }
  let(:edit_path) { edit_gws_riken_payment_workflow_sample_path site.id, item }
  let(:delete_path) { delete_gws_riken_payment_workflow_sample_path site.id, item }

  context "with auth" do
    before { login_gws_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path
    end

    it "#new" do
      visit new_path
      within "form#item-form" do
        fill_in "item[name]", with: name
        fill_in "item[workflow_id]", with: workflow_id
        fill_in "item[status]", with: status
        fill_in "item[url]", with: url
        fill_in "item[update_time]", with: update_time
        fill_in "item[delegation_start_date]", with: delegation_start_date
        fill_in "item[delegation_end_date]", with: delegation_end_date
        fill_in "item[proxy_id]", with: proxy_id
        fill_in "item[proxy_name]", with: proxy_name
        fill_in "item[proxy_lab]", with: proxy_lab
        fill_in "item[proxy_position]", with: proxy_position
        fill_in "item[authorizer_id]", with: authorizer_id
        fill_in "item[authorizer_name]", with: authorizer_name
        fill_in "item[authorizer_lab]", with: authorizer_lab
        fill_in "item[authorizer_position]", with: authorizer_position
        fill_in "item[delegation_1]", with: delegation_1
        fill_in "item[delegation_2]", with: delegation_2
        fill_in "item[delegation_3]", with: delegation_3
        fill_in "item[note]", with: note
        fill_in "item[create_time]", with: create_time
        fill_in "item[create_id]", with: create_id
        fill_in "item[create_name]", with: create_name
        fill_in "item[create_lab]", with: create_lab
        fill_in "item[create_position]", with: create_position
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
    end

    it "#show" do
      visit show_path
      expect(page).to have_css("#addon-basic", text: item.name)
    end

    it "#edit" do
      visit edit_path
      within "form#item-form" do
        fill_in "item[name]", with: "modify"
        click_button I18n.t('ss.buttons.save')
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
      expect(page).to have_css("#addon-basic", text: "modify")
    end

    it "#delete" do
      visit delete_path
      within "form" do
        click_button I18n.t('ss.buttons.delete')
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.deleted'))
    end
  end
end
