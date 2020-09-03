require 'spec_helper'

describe "tourism_pages", type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:layout) { create_cms_layout }

  let!(:node) { create_once :tourism_node_page, filename: "docs", name: "tourism" }
  let!(:item) { create(:tourism_page, cur_node: node, layout_id: layout.id, facility: facility_page) }

  let!(:facility_node)   { create :facility_node_node, layout_id: layout.id, filename: "node" }
  let!(:facility_page) do
    create(:facility_node_page, filename: "node/item", cur_node: facility_node,
           kana: "kana", postcode: "postcode", address: "address", tel: "tel",
           fax: "fax", related_url: "related_url", additional_info: [{:field=>"additional_info", :value=>"additional_info"}])
  end
  let!(:map) do
    create :facility_map, filename: "node/item/#{unique_id}",
           map_points: [{"name" => facility_page.name, "loc" => [34.067035, 134.589971], "text" => unique_id}]
  end
  let!(:file) {create :ss_file}
  let!(:image) do
    create :facility_image, filename: "node/item/#{unique_id}", image_id: file.id
  end

  let(:index_path) { tourism_pages_path site.id, node }
  let(:new_path) { new_tourism_page_path site.id, node }
  let(:show_path) { tourism_page_path site.id, node, item }
  let(:edit_path) { edit_tourism_page_path site.id, node, item }
  let(:delete_path) { delete_tourism_page_path site.id, node, item }

  context "basic crud" do
    before { login_cms_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path
    end

    it "#new" do
      visit new_path
      within "form#item-form" do
        fill_in "item[name]", with: "sample"
        click_on I18n.t("ss.links.input")
        fill_in "item[basename]", with: "sample"
        click_on I18n.t("ss.buttons.draft_save")
      end
      click_on I18n.t("ss.buttons.ignore_alert")
      expect(page).to have_css("#errorExplanation", text: "施設を入力してください。")

      within '#addon-tourism-agents-addons-facility' do
        click_on "施設を選択する"
      end
      wait_for_cbox do
        click_on facility_page.name
      end

      within "form#item-form" do
        click_on I18n.t("ss.buttons.draft_save")
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
        click_on I18n.t("ss.buttons.publish_save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
    end

    it "#delete" do
      visit delete_path
      within "form" do
        click_on I18n.t("ss.buttons.delete")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.deleted'))
    end
  end
end
