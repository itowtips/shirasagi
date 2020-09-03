require 'spec_helper'

describe "tourism_agents_nodes_notice", type: :feature, dbscope: :example do
  let(:site)   { cms_site }
  let(:layout) { create_cms_layout }

  let!(:node) { create_once :tourism_node_notice, filename: "docs", name: "tourism" }
  let!(:item) { create(:tourism_notice, cur_node: node, layout_id: layout.id, facility: facility_page) }

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

  context "public" do
    before do
      Capybara.app_host = "http://#{site.domain}"
    end

    it "#index" do
      visit node.url
      expect(page).to have_css(".tourism-pages")
      expect(page).to have_selector(".tourism-pages article")
      expect(page).to have_selector("a[href='" + item.url + "']")
    end

    it "#rss" do
      visit "#{node.url}rss.xml"
      expect(page).to have_content(item.full_url)
    end
  end
end
