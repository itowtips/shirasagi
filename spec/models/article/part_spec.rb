require 'spec_helper'

describe Article::Part::Page, type: :model, dbscope: :example do
  let(:item) { create :article_part_page }
  it_behaves_like "cms_part#spec"

  describe '#render_loop_html - name' do
    let(:page) { create(:article_page, name: 'ページ &') }

    it do
      expect(item.render_loop_html(page, html: '#{name}')).to eq('ページ &amp;')
    end
  end

  describe '#render_loop_html - url' do
    let(:page) { create(:article_page) }

    it do
      expect(item.render_loop_html(page, html: '#{url}')).to eq(page.url)
    end
  end

  describe '#render_loop_html - summary' do
    let(:html) do
      <<-HTML
        <!doctype html>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="ja">

        <head>
        <meta charset="UTF-8" />
        <title>自治体サンプル</title>
        <link rel="stylesheet" media="screen" href="/assets/cms/public.css" />
        <script src="/assets/cms/public.js"></script>

          <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=yes,minimum-scale=1.0,maximum-scale=2.0">
          <link href="/css/style.css" media="all" rel="stylesheet" }}
          <script src="/js/common.js"></script>
          <!--[if lt IE 9]>
          <script src="/js/selectivizr.js"></script>
          <script src="/js/html5shiv.js"></script>
          <![endif]-->


        </head>

        <body id="body--index" class="">
        <div id="page">

        <div id="tool">
        <nav>
          <a id="nocssread" href="#wrap">本文へ</a>
          <div id="size">文字サイズ<span id="ss-small">小さく</span><span id="ss-medium">標準</span><span id="ss-large">大きく</span></div>
          <span id="ss-voice">読み上げる</span>
          <span id="ss-kana">ふりがなをつける</span>
          <a id="info" href="/use/">ご利用案内</a>
        </nav>
        </div>
      HTML
    end
    let(:page) { create(:article_page, html: html) }
    let(:expected_summary) { '自治体サンプル 本文へ 文字サイズ小さく標準大きく 読み上げる ふりがなをつける ご利用案内' }

    it do
      expect(item.render_loop_html(page, html: '#{summary}')).to eq(expected_summary)
    end
  end

  describe '#render_loop_html - class' do
    let(:page) { create(:article_page) }

    it do
      expect(item.render_loop_html(page, html: '#{class}')).to eq(page.basename.sub(/\..*/, "").dasherize)
    end
  end

  describe '#render_loop_html - new' do
    context 'new page' do
      let(:page) { create(:article_page) }

      it do
        expect(item.render_loop_html(page, html: '#{new}')).to eq('new')
      end
    end

    context 'not new page' do
      let(:page) { create(:article_page, released: Time.zone.now - 31.days) }

      it do
        expect(item.render_loop_html(page, html: '#{new}')).to eq ''
      end
    end
  end

  describe '#render_loop_html - date' do
    let(:page) { create(:article_page) }

    it 'date' do
      expect(item.render_loop_html(page, html: '#{date}')).to eq(I18n.l(page.date.to_date))
    end
    it 'date.default' do
      expect(item.render_loop_html(page, html: '#{date.default}')).to eq(I18n.l(page.date.to_date, format: :default))
    end
    it 'date.iso' do
      expect(item.render_loop_html(page, html: '#{date.iso}')).to eq(I18n.l(page.date.to_date, format: :iso))
    end
    it 'date.long' do
      expect(item.render_loop_html(page, html: '#{date.long}')).to eq(I18n.l(page.date.to_date, format: :long))
    end
    it 'date.short' do
      expect(item.render_loop_html(page, html: '#{date.short}')).to eq(I18n.l(page.date.to_date, format: :short))
    end
  end

  describe '#render_loop_html - time' do
    let(:page) { create(:article_page) }

    it 'time' do
      expect(item.render_loop_html(page, html: '#{time}')).to eq(I18n.l(page.date))
    end
    it 'time.default' do
      expect(item.render_loop_html(page, html: '#{time.default}')).to eq(I18n.l(page.date, format: :default))
    end
    it 'time.iso' do
      expect(item.render_loop_html(page, html: '#{time.iso}')).to eq(I18n.l(page.date, format: :iso))
    end
    it 'time.long' do
      expect(item.render_loop_html(page, html: '#{time.long}')).to eq(I18n.l(page.date, format: :long))
    end
    it 'time.short' do
      expect(item.render_loop_html(page, html: '#{time.short}')).to eq(I18n.l(page.date, format: :short))
    end
  end

  describe '#render_loop_html - group' do
    context 'no group' do
      let(:page) { create(:article_page) }

      it do
        expect(item.render_loop_html(page, html: '#{group}')).to eq('')
      end
    end

    context '1 group' do
      let(:group) { cms_group }
      let(:page) { create(:article_page, group_ids: [group.id]) }

      it do
        expect(item.render_loop_html(page, html: '#{group}')).to eq(group.name)
      end
    end
  end

  describe '#render_loop_html - groups' do
    context 'no group' do
      let(:page) { create(:article_page) }

      it do
        expect(item.render_loop_html(page, html: '#{groups}')).to eq('')
      end
    end

    context '1 group' do
      let(:group) { cms_group }
      let(:page) { create(:article_page, group_ids: [group.id]) }

      it do
        expect(item.render_loop_html(page, html: '#{groups}')).to eq(group.name)
      end
    end

    context '2 groups' do
      let(:group1) { cms_group }
      let(:group2) { create(:cms_group, name: 'グループ2') }
      let(:page) { create(:article_page, group_ids: [group1.id, group2.id]) }

      it do
        expect(item.render_loop_html(page, html: '#{groups}')).to eq("#{group1.name}, #{group2.name}")
      end
    end
  end

  describe '#render_loop_html - img.src' do
    context 'extract from /img' do
      let(:html) do
        <<-HTML
          <div class="logo">
            <h1><a id="xss-site-name" href="/"><img src="/img/logo.png" alt="SHIRASAGI市" title="SHIRASAGI市" /></a></h1>
          </div>
        HTML
      end
      let(:page) { create(:article_page, html: html) }

      it do
        expect(item.render_loop_html(page, html: '#{img.src}')).to eq('/img/logo.png')
      end
    end

    context 'extract from /fs' do
      let(:html) do
        <<-HTML
          <div class="banners">
            <span>
              <a href="/add/600.html?redirect=http://www.ss-proj.org/" >
                  <img alt="シラサギ" src="/fs/2/_/dummy_banner_1.gif" />
              </a>
            </span>
            <span>
              <a href="/add/601.html?redirect=http://www.ss-proj.org/" >
                  <img alt="シラサギ" src="/fs/4/_/dummy_banner_2.gif" />
              </a>
            </span>
          </div>
        HTML
      end
      let(:page) { create(:article_page, html: html) }

      it do
        expect(item.render_loop_html(page, html: '#{img.src}')).to eq('/fs/2/_/dummy_banner_1.gif')
      end
    end

    context 'extract from ../img' do
      let(:html) do
        <<-HTML
          <div class="logo">
            <h1><a id="xss-site-name" href="/"><img src="../img/logo.png" alt="SHIRASAGI市" title="SHIRASAGI市" /></a></h1>
          </div>
        HTML
      end
      let(:page) { create(:article_page, html: html) }

      it do
        expect(item.render_loop_html(page, html: '#{img.src}')).to eq("#{File.dirname(page.url)}/../img/logo.png")
      end
    end

    context 'extract from external web site 1' do
      let(:html) do
        <<-HTML
          <div class="site hatena">
            <a href="http://b.hatena.ne.jp/entry/http://tokushima-wifi.jp/use/index.html" class="hatena-bookmark-button"
              data-hatena-bookmark-layout="standard-balloon"
              data-hatena-bookmark-lang="ja" title="このエントリーをはてなブックマークに追加">
              <img src="//b.st-hatena.com/images/entry-button/button-only@2x.png"
                alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a>
            <script type="text/javascript" src="//b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>
          </div>
        HTML
      end
      let(:page) { create(:article_page, html: html) }

      it do
        expect(item.render_loop_html(page, html: '#{img.src}')).to \
          eq('//b.st-hatena.com/images/entry-button/button-only@2x.png')
      end
    end
  end

  context 'extract from external web site 2' do
    let(:html) do
      <<-HTML
          <div class="site hatena">
            <a href="http://b.hatena.ne.jp/entry/http://tokushima-wifi.jp/use/index.html" class="hatena-bookmark-button"
              data-hatena-bookmark-layout="standard-balloon"
              data-hatena-bookmark-lang="ja" title="このエントリーをはてなブックマークに追加">
              <img src="https://b.st-hatena.com/images/entry-button/button-only@2x.png"
                alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a>
            <script type="text/javascript" src="//b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>
          </div>
      HTML
    end
    let(:page) { create(:article_page, html: html) }

    it do
      expect(item.render_loop_html(page, html: '#{img.src}')).to \
        eq('https://b.st-hatena.com/images/entry-button/button-only@2x.png')
    end
  end

  describe '#render_loop_html - categories' do
    context 'empty categories' do
      let(:page) { create(:article_page) }

      it do
        expect(item.render_loop_html(page, html: '#{categories}')).to eq('')
      end
    end

    context '2 categories' do
      let(:category_root) { create(:category_node_node, name: 'カテゴリ') }
      let(:category1) { create(:category_node_page, node: category_root, name: 'スポーツ >') }
      let(:category2) { create(:category_node_page, node: category_root, name: '音楽 &') }
      let(:page) { create(:article_page, category_ids: [category1.id, category2.id]) }
      let(:expected1) do
        "<span class=\"#{category1.filename.tr('/', '-')}\"><a href=\"#{category1.url}\">スポーツ &gt;</a></span>"
      end
      let(:expected2) do
        "<span class=\"#{category2.filename.tr('/', '-')}\"><a href=\"#{category2.url}\">音楽 &amp;</a></span>"
      end

      it do
        ret = item.render_loop_html(page, html: '#{categories}')
        expect(ret).to include(expected1)
        expect(ret).to include(expected2)
      end
    end
  end

  describe '#render_loop_html - pages.count' do
    context 'page under the category' do
      let!(:category_root) { create(:category_node_node, name: 'カテゴリ') }
      let!(:category) { create(:category_node_page, node: category_root, name: 'スポーツ >') }
      let!(:page) { create(:article_page, node: category) }

      it 'node contains 1 page' do
        ret = item.render_loop_html(category, html: '#{pages.count}')
        expect(ret).to eq('1')
      end

      it 'node contains no pages' do
        ret = item.render_loop_html(category_root, html: '#{pages.count}')
        expect(ret).to eq('0')
      end

      it 'pages.count on the page' do
        ret = item.render_loop_html(page, html: '#{pages.count}')
        expect(ret).to eq '0'
      end
    end

    context 'page related to category' do
      let!(:category_root) { create(:category_node_node, name: 'カテゴリ') }
      let!(:category) { create(:category_node_page, node: category_root, name: 'スポーツ >') }
      let!(:page) { create(:article_page, category_ids: [category.id]) }

      it 'node contains 1 page' do
        ret = item.render_loop_html(category, html: '#{pages.count}')
        expect(ret).to eq('1')
      end

      it 'node contains no pages' do
        ret = item.render_loop_html(category_root, html: '#{pages.count}')
        expect(ret).to eq('0')
      end

      it 'pages.count on the page' do
        ret = item.render_loop_html(page, html: '#{pages.count}')
        expect(ret).to eq '0'
      end
    end

    context 'page related to category' do
      let!(:category_root) { create(:category_node_node, name: 'カテゴリ') }
      let!(:category) { create(:category_node_page, node: category_root, name: 'スポーツ >') }
      let!(:page) { create(:article_page, node: category, category_ids: [category.id]) }

      it 'node contains 1 page' do
        ret = item.render_loop_html(category, html: '#{pages.count}')
        expect(ret).to eq('1')
      end

      it 'node contains no pages' do
        ret = item.render_loop_html(category_root, html: '#{pages.count}')
        expect(ret).to eq('0')
      end

      it 'pages.count on the page' do
        ret = item.render_loop_html(page, html: '#{pages.count}')
        expect(ret).to eq '0'
      end
    end
  end
end
