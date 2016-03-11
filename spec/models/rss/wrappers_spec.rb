require 'spec_helper'

describe Rss::Wrappers, dbscope: :example do
  describe ".parse" do
    context "when rdf is given" do
      let(:file) { Rails.root.join("spec", "fixtures", "rss", "sample-rdf.xml") }
      subject do
        rss = described_class.parse(file)
        items = []
        rss.each do |item|
          items << { name: item.name, link: item.link, html: item.html, released: item.released, authors: item.authors }
        end
        items
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[0][:name]).to eq '記事1'
        expect(subject[0][:link]).to eq 'http://example.jp/rdf/1.html'
        expect(subject[0][:html]).to eq '本文1'
        expect(subject[0][:released]).to eq Time.zone.parse('2015-06-12T19:00:00+09:00')
        expect(subject[0][:authors]).to include(name: '鶴田 結衣')
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[1][:name]).to eq '記事2'
        expect(subject[1][:link]).to eq 'http://example.jp/rdf/2.html'
        expect(subject[1][:html]).to eq '本文2'
        expect(subject[1][:released]).to eq Time.zone.parse('2015-06-11T14:00:00+09:00')
        expect(subject[1][:authors]).to eq []
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[2][:name]).to eq '記事3'
        expect(subject[2][:link]).to eq 'http://example.jp/rdf/3.html'
        expect(subject[2][:html]).to eq '本文3'
        expect(subject[2][:released]).to eq Time.zone.parse('2015-06-10T09:00:00+09:00')
        expect(subject[2][:authors]).to eq []
      end
    end

    context "when rss is given" do
      let(:file) { Rails.root.join("spec", "fixtures", "rss", "sample-rss.xml") }
      subject do
        rss = described_class.parse(file)
        items = []
        rss.each do |item|
          items << { name: item.name, link: item.link, html: item.html, released: item.released, authors: item.authors }
        end
        items
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[0][:name]).to eq '記事1'
        expect(subject[0][:link]).to eq 'http://example.jp/rss/1.html'
        expect(subject[0][:html]).to eq '本文1'
        expect(subject[0][:released]).to eq Time.zone.parse('2015-06-12T19:00:00+09:00')
        expect(subject[0][:authors]).to include(email: "momose_tomoka@example.com (百瀬 友香)")
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[1][:name]).to eq '記事2'
        expect(subject[1][:link]).to eq 'http://example.jp/rss/2.html'
        expect(subject[1][:html]).to eq '本文2'
        expect(subject[1][:released]).to eq Time.zone.parse('2015-06-11T14:00:00+09:00')
        expect(subject[1][:authors]).to eq []
      end

      it do
        expect(subject.length).to eq 5
        expect(subject[2][:name]).to eq '記事3'
        expect(subject[2][:link]).to eq 'http://example.jp/rss/3.html'
        expect(subject[2][:html]).to eq '本文3'
        expect(subject[2][:released]).to eq Time.zone.parse('2015-06-10T09:00:00+09:00')
        expect(subject[2][:authors]).to eq []
      end
    end

    context "when atom is given" do
      let(:file) { Rails.root.join("spec", "fixtures", "rss", "sample-atom.xml") }
      subject do
        rss = described_class.parse(file)
        items = []
        rss.each do |item|
          items << { name: item.name, link: item.link, html: item.html, released: item.released, authors: item.authors }
        end
        items
      end

      it do
        expect(subject.length).to eq 5
      end

      it do
        expect(subject[0][:name]).to eq '記事1'
        expect(subject[0][:link]).to eq 'http://example.jp/atom/1.html'
        expect(subject[0][:html]).to eq '本文1'
        expect(subject[0][:released]).to eq Time.zone.parse('2015-06-12T19:00:00+09:00')
        expect(subject[0][:authors]).to include(name: '臼井 杏', email: 'usui_ann@example.com', uri: 'http://example.com/usui_ann')
      end

      it do
        # second item's summary is xhtml
        expect(subject[1][:name]).to eq '記事2'
        expect(subject[1][:link]).to eq 'http://example.jp/atom/2.html'
        expect(subject[1][:html]).to eq '<div xmlns="http://www.w3.org/1999/xhtml">本文2</div>'
        expect(subject[1][:released]).to eq Time.zone.parse('2015-06-11T14:00:00+09:00')
        expect(subject[1][:authors]).to include(name: '落合 フミヤ')
      end

      it do
        # third item's title is xhtml
        expect(subject[2][:name]).to eq '記事3'
        expect(subject[2][:link]).to eq 'http://example.jp/atom/3.html'
        expect(subject[2][:html]).to eq '本文3'
        expect(subject[2][:released]).to eq Time.zone.parse('2015-06-10T09:00:00+09:00')
        expect(subject[2][:authors]).to eq []
      end
    end
  end

  context "when weather xml is given" do
    let(:file) { Rails.root.join("spec", "fixtures", "rss", "weather-sample.xml") }
    subject do
      rss = described_class.parse(file)
      items = []
      rss.each do |item|
        items << { name: item.name, link: item.link, html: item.html, released: item.released, authors: item.authors }
      end
      items
    end

    it do
      expect(subject.length).to eq 2
    end

    it do
      expect(subject[0][:name]).to eq '気象警報・注意報'
      expect(subject[0][:link]).to eq 'http://xml.kishou.go.jp/data/afeedc52-107a-3d1d-9196-b108234d6e0f.xml'
      expect(subject[0][:html]).to eq '【福島県気象警報・注意報】注意報を解除します。'
      expect(subject[0][:released]).to eq Time.zone.parse('2016-03-10T09:22:41Z')
      expect(subject[0][:authors]).to include(name: '福島地方気象台')
    end

    it do
      expect(subject[1][:name]).to eq '気象特別警報・警報・注意報'
      expect(subject[1][:link]).to eq 'http://xml.kishou.go.jp/data/2b441518-4e79-342c-a271-7c25597f3a69.xml'
      expect(subject[1][:html]).to eq '【福島県気象警報・注意報】注意報を解除します。'
      expect(subject[1][:released]).to eq Time.zone.parse('2016-03-10T09:22:41Z')
      expect(subject[1][:authors]).to include(name: '福島地方気象台')
    end
  end
end
