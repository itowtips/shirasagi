require 'spec_helper'

describe "workflow_branch", type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:old_name) { "[TEST] br_page" }
  let(:old_index_name) { "[TEST] br_page" }
  let(:new_name) { "[TEST] br_replace" }
  let(:new_index_name) { "" }

  before { login_cms_user }

  def create_branch
    # create_branch
    visit show_path
    click_button I18n.t('workflow.create_branch')

    # show branch
    click_link old_name
    expect(page).to have_css('.see.branch', text: I18n.t('workflow.branch_message'))

    # draft save
    click_on I18n.t('ss.links.edit')
    within "#item-form" do
      fill_in "item[name]", with: new_name
      fill_in "item[index_name]", with: new_index_name
      click_on I18n.t('ss.buttons.draft_save')
    end
    wait_for_ajax
    expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

    master = item.class.where(name: old_name).first
    branch = item.class.where(name: new_name).first

    expect(master.state).to eq "public"
    expect(branch.state).to eq "closed"
    expect(master.branches.first.id).to eq(branch.id)

    branch_url = show_path.sub(/\/\d+$/, "/#{branch.id}")
    publish_branch(branch_url)
  end

  def publish_branch(branch_url)
    visit branch_url
    expect(page).to have_css('.see.branch', text: I18n.t('workflow.branch_message'))

    # publish branch
    click_on I18n.t('ss.links.edit')
    within "#item-form" do
      click_on I18n.t('ss.buttons.publish_save')
    end
    wait_for_notice I18n.t('ss.notice.saved')

    # master was replaced
    item.class.all.each do |pub|
      expect(pub.name).to eq new_name
      expect(pub.index_name).to be_blank
      expect(pub.state).to eq "public"
    end
    expect(item.class.all.size).to eq 1
  end

  context "tourism page" do
    let(:layout) { create_cms_layout }
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

    let!(:node) { create_once :tourism_node_notice, filename: "docs", name: "tourism" }
    let(:item) { create(:tourism_notice, cur_node: node, layout: layout.id, facility: facility_page, name: old_name, index_name: old_index_name) }
    let(:show_path) { tourism_notice_path site.id, node, item }
    it { create_branch }
  end
end
