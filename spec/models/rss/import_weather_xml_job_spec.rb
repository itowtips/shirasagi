require 'spec_helper'

describe Rss::ImportWeatherXmlJob, dbscope: :example do
  after(:all) do
    WebMock.reset!
  end

  context "when importing weather sample xml" do
    let(:site) { cms_site }
    let(:filepath) { Rails.root.join(*%w(spec fixtures rss weather-sample.xml)) }
    let(:node) { create(:rss_node_pub_sub_hubbub, cur_site: site, page_state: 'closed') }
    let(:file) { Rss::TempFile.create_from_post(site, File.read(filepath), 'application/xml+rss') }
    let(:model) { Rss::WeatherXmlPage }
    let(:xml1) { File.read(Rails.root.join(*%w(spec fixtures rss afeedc52-107a-3d1d-9196-b108234d6e0f.xml))) }
    let(:xml2) { File.read(Rails.root.join(*%w(spec fixtures rss 2b441518-4e79-342c-a271-7c25597f3a69.xml))) }

    before do
      stub_request(:get, 'http://xml.kishou.go.jp/data/afeedc52-107a-3d1d-9196-b108234d6e0f.xml').
        to_return(body: xml1, status: 200, headers: { 'Content-Type' => 'application/xml' })
      stub_request(:get, 'http://xml.kishou.go.jp/data/2b441518-4e79-342c-a271-7c25597f3a69.xml').
        to_return(body: xml2, status: 200, headers: { 'Content-Type' => 'application/xml' })
    end

    it do
      expect { described_class.new.call(site.host, node.id, nil, file.id) }.to change { model.count }.from(0).to(2)
      item = model.where(rss_link: 'http://xml.kishou.go.jp/data/afeedc52-107a-3d1d-9196-b108234d6e0f.xml').first
      expect(item).not_to be_nil
      expect(item.name).to eq '気象警報・注意報'
      expect(item.rss_link).to eq 'http://xml.kishou.go.jp/data/afeedc52-107a-3d1d-9196-b108234d6e0f.xml'
      expect(item.html).to eq '【福島県気象警報・注意報】注意報を解除します。'
      expect(item.released).to eq Time.zone.parse('2016-03-10T09:22:41Z')
      expect(item.authors.count).to eq 1
      expect(item.authors.first.name).to eq '福島地方気象台'
      expect(item.authors.first.email).to be_nil
      expect(item.authors.first.uri).to be_nil
      expect(item.xml).not_to be_nil
      expect(item.xml).to include('<InfoKind>気象警報・注意報</InfoKind>')
      expect(item.state).to eq 'closed'
    end
  end
end
