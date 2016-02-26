require 'spec_helper'

describe Rss::ImportWeatherXmlJob, dbscope: :example do
  context "when importing weather sample xml" do
    let(:site) { cms_site }
    let(:filepath) { Rails.root.join(*%w(spec fixtures rss weather-sample.xml)) }
    let(:node) { create(:rss_node_pub_sub_hubbub, cur_site: site, page_state: 'closed') }
    let(:file) { Rss::TempFile.create_from_post(site, File.read(filepath), 'application/xml+rss') }
    let(:model) { Rss::WeatherXmlPage }

    it do
      expect { described_class.new.call(site.host, node.id, nil, file.id) }.to change { model.count }.from(0).to(2)
      item = model.where(rss_link: 'http://*/*/8e55b8d8-518b-3dc9-9156-7e87c001d7b5.xml').first
      expect(item).not_to be_nil
      expect(item.name).to eq '気象警報・注意報'
      expect(item.rss_link).to eq 'http://*/*/8e55b8d8-518b-3dc9-9156-7e87c001d7b5.xml'
      expect(item.html).to eq '【富山県気象警報・注意報】富山県では、強風、高波に注意してください。'
      expect(item.released).to eq Time.zone.parse('2012-08-15T07:00:00+09:00')
      expect(item.authors.count).to eq 1
      expect(item.authors.first.name).to eq '富山地方気象台'
      expect(item.authors.first.email).to be_nil
      expect(item.authors.first.uri).to be_nil
      expect(item.state).to eq 'closed'
    end
  end
end
