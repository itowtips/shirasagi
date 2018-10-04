namespace :szod do

  task create_categories: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?

    site = ::Cms::Site.where(host: ENV['site']).first

filenames = %w(
kurashi
kurashi/syouhi
kurashi/syoku
kurashi/bousai
kurashi/shizen
kurashi/recycle
kurashi/suido
kurashi/kenchiku
kurashi/npo
kurashi/jinken
kurashi/univ

kenko
kenko/iryo
kenko/yobo
kenko/kosodate
kenko/hukushi
kenko/syogai
kenko/eisei
kenko/byoin
kenko/faruma

kyoiku
kyoiku/gako
kyoiku/syogai
kyoiku/bunka

sangyo
sangyo/norin
sangyo/suisan
sangyo/nouson
sangyo/syouko
sangyo/koyo
sangyo/it
sangyo/kigyo
sangyo/kenkyu
sangyo/energy

koryu
koryu/tochi
koryu/douro
koryu/kasen
koryu/kukou
koryu/kokusai
koryu/chiki

kensei
kensei/sogou
kensei/plan
kensei/gyosei
kensei/zaisei
kensei/jyorei
kensei/tokei
kensei/jyosei
kensei/kokyo
kensei/gikai
kensei/kisya

sonota
)

names = %w(
くらし・環境
消費生活
食生活
防災・安全・防犯
自然・環境
リサイクル・廃棄物
水道・下水道
建築・住宅
ボランティア・NPO
人権・男女共同参画
ユニバーサルデザイン

健康・福祉
医療
健康づくり・疾病対策と感染症の予防
子ども・子育て
社会福祉・高齢者福祉
障害福祉
衛生・薬事
病院・がんセンター
ファルマバレープロジェクト

教育・文化
学校教育
生涯学習
文化・スポーツ・観光

産業・雇用
農林業
水産業
農山村・農地
商工・サービス業
雇用・労働
IT・情報化
企業支援
研究開発
エネルギー

交流・まちづくり
土地・都市計画
道路
河川・港湾
空港・交通
国際交流
地域振興

県政情報
県政総合
計画・プラン・構想
行政改革・情報公開
財政・県税・出納・監査
条例・規則・公報
統計・調査
助成・融資
公共工事・入札情報
議会・選挙
記者発表資料

その他
)

estat_filenames = %w(
kurashi
kurashi/syouhi
kurashi/syoku
kurashi/bousai
kurashi/shizen
kurashi/recycle
kurashi/suido
kurashi/kenchiku
kurashi/npo
kurashi/jinken
kurashi/univ

kenko
kenko/iryo
kenko/yobo
kenko/kosodate
kenko/hukushi
kenko/syogai
kenko/eisei
kenko/byoin
kenko/faruma

kyoiku
kyoiku/gako
kyoiku/syogai
kyoiku/bunka

sangyo
sangyo/norin
sangyo/suisan
sangyo/nouson
sangyo/syouko
sangyo/koyo
sangyo/it
sangyo/kigyo
sangyo/kenkyu
sangyo/energy

koryu
koryu/tochi
koryu/douro
koryu/kasen
koryu/kukou
koryu/kokusai
koryu/chiki

kensei
kensei/sogou
kensei/plan
kensei/gyosei
kensei/zaisei
kensei/jyorei
kensei/tokei
kensei/jyosei
kensei/kokyo
kensei/gikai
kensei/kisya

sonota
)

estat_names = %w(
国土・気象

人口・世帯
人口
世帯
人口動態
人口移動

労働・賃金
労働力
賃金・労働条件
雇用
労使関係
労働災害

農林水産業
農業
畜産業
林業
水産業

鉱工業
鉱業
製造業

商業・サービス業
商業
需給流通
サービス業

企業・家計・経済
企業活動
金融・保険・通貨
物価
家計
国民経済計算
景気

住宅・土地・建設
住宅・土地
建設

エネルギー・水
電気
ガス
エネルギー需給
水

運輸・観光
運輸
倉庫
観光

情報通信・科学技術
情報通信・放送
科学技術
知的財産

教育・文化・スポーツ・生活
学校教育
社会教育
文化・スポーツ・生活

行財政
行政
財政
公務員
選挙

司法・安全・環境
司法
犯罪
災害
事故
環境

社会保障・衛生
社会保障
社会保険
社会福祉
保険衛生
医療

国際
貿易・国際趣旨
国際協力

その他
)

estat_filenames = %w(
estat/estat01

estat/estat01/estat02
estat/estat01/estat03
estat/estat01/estat04
estat/estat01/estat05
estat/estat01/estat06

estat/estat07
estat/estat07/estat08
estat/estat07/estat09
estat/estat07/estat10
estat/estat07/estat11
estat/estat07/estat12

estat/estat13
estat/estat13/estat14
estat/estat13/estat15
estat/estat13/estat16
estat/estat13/estat17

estat/estat18
estat/estat18/estat19
estat/estat18/estat20

estat/estat21
estat/estat21/estat22
estat/estat21/estat23
estat/estat21/estat24

estat/estat25
estat/estat25/estat26
estat/estat25/estat27
estat/estat25/estat28
estat/estat25/estat29
estat/estat25/estat30
estat/estat25/estat31

estat/estat32
estat/estat32/estat33
estat/estat32/estat34

estat/estat35
estat/estat35/estat36
estat/estat35/estat37
estat/estat35/estat38
estat/estat35/estat39

estat/estat40
estat/estat40/estat41
estat/estat40/estat42
estat/estat40/estat43

estat/estat44
estat/estat44/estat45
estat/estat44/estat46
estat/estat44/estat47

estat/estat48
estat/estat48/estat49
estat/estat48/estat50
estat/estat48/estat51

estat/estat52
estat/estat52/estat53
estat/estat52/estat54
estat/estat52/estat55
estat/estat52/estat56

estat/estat57
estat/estat57/estat58
estat/estat57/estat59
estat/estat57/estat60
estat/estat57/estat61
estat/estat57/estat62

estat/estat63
estat/estat63/estat64
estat/estat63/estat65
estat/estat63/estat66
estat/estat63/estat67
estat/estat63/estat68

estat/estat69
estat/estat69/estat70
estat/estat69/estat71

estat/estat72
)

    names.each_with_index do |name, idx|
      filename = ::File.join("bunya", filenames[idx])

      item = ::Opendata::Node::Category.find_or_initialize_by(site_id: site.id, filename: filename)
      item.name = name
      item.filename = filename
      item.cur_site = site

      puts "#{name} #{filename}"
      item.save!
    end

    estat_names.each_with_index do |name, idx|
      filename = estat_filenames[idx]

      item = ::Opendata::Node::EstatCategory.find_or_initialize_by(site_id: site.id, filename: filename)
      item.name = name
      item.filename = filename
      item.cur_site = site

      puts "#{name} #{filename}"
      item.save!
    end
  end

  task export_fuji_csv: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    puts "Please input node: node=[node]" or exit if ENV['node'].blank?

    blocks = [
      ["静岡県", 139],
      ["静岡市", 145],
      ["沼津市", 161],
      ["熱海市", 167],
      ["三島市", 173],
      ["富士宮市", 179],
      ["伊東市", 216],
      ["島田市", 147],
      ["富士市", 153],
      ["磐田市", 163],
      ["焼津市", 169],
      ["掛川市", 175],
      ["藤枝市", 181],
      ["御殿場市", 143],
      ["袋井市", 149],
      ["下田市", 159],
      ["裾野市", 165],
      ["湖西市", 171],
      ["伊豆市", 177],
      ["御前崎市", 183],
      ["菊川市", 185],
      ["伊豆の国市", 187],
      ["牧之原市", 189],
      ["賀茂郡 東伊豆町", 191],
      ["賀茂郡 河津町", 193],
      ["賀茂郡 南伊豆町", 195],
      ["賀茂郡 松崎町", 197],
      ["賀茂郡 西伊豆町", 199],
      ["田方郡 函南町", 201],
      ["駿東郡 清水町", 203],
      ["駿東郡 長泉町", 205],
      ["駿東郡 小山町", 207],
      ["榛原郡 吉田町", 209],
      ["榛原郡 川根本町", 211],
      ["周智郡 森町", 213],
      ["賀茂地域", 253],
      ["民間データ", 218],
    ]

    site = ::Cms::Site.where(host: ENV['site']).first
    node = ::Opendata::Node::Dataset.site(site).where(id: ENV['node']).first

    dataset_urls = {}
    base_url = "https://open-data.pref.shizuoka.jp/index.php?action=multidatabase_view_main_init&visible_item=1000000000"

    blocks.each do |name, block_id|
      dataset_urls[name] = []

      url =  base_url + "&block_id=#{block_id}"
      html = open(url).read
      sleep 1

      doc = Nokogiri::HTML.parse(html, nil, "utf-8")
      title = doc.css(".content .outerdiv .bold").text
      puts "#{title} #{url}"

      doc.css("table#_#{block_id} td").css('a[title="コンテンツの詳細を表示する。"]').each do |a_tag|
        dataset_urls[name] << a_tag.attributes["href"].value
      end
    end

    datasets = []
    dataset_urls.each do |name, urls|

      puts urls.count

      urls.each_with_index do |url, idx|
        begin
        dataset = {}

        puts "#{idx + 1} : #{name} #{url}"

        html = open(url).read
        doc = Nokogiri::HTML.parse(html, nil, "utf-8")
        sleep 1

        dataset["area"] = name

        # url
        dataset["url"] = url

        # name
        tr = nil
        doc.css("th").each do |th|
          if th.text == "データ名称"
            tr = th.parent
            break
          end
        end
        dataset["name"] = tr.css("td").text.strip

        # text
        tr = nil
        doc.css("th").each do |th|
          if th.text == "データ概要"
            tr = th.parent
            break
          end
        end
        dataset["text"] = tr.css("td").text.strip

        # license
        tr = nil
        doc.css("th").each do |th|
          if th.text =~ /ライセンス/
            tr = th.parent
            break
          end
        end
        dataset["license"] = tr.css("th").text.strip

        # resouces
        dataset["resouces"] = []
        table = doc.css("table").select do |table|
          table.text =~ /（１）データ形式/ && table.text =~ /（２）データ形式/
        end.first
        tr = table.css("th").select { |th| th.text =~ /（.+?データ$/ }.map do |th|
          th.parent
        end
        tr.each do |tr_tag|
          a_tag = tr_tag.css("a").first
          next unless a_tag

          resouce = {}

          href = a_tag.attributes["href"].value
          if href =~ /^\.\/\?action/
            resouce["url"] = a_tag.attributes["href"].value
            resouce["format"] =  ::File.extname(a_tag.text).delete(".")
          else
            resouce["source_url"] = a_tag.attributes["href"].value
          end

          resouce["filename"] = a_tag.text.strip
          dataset["resouces"] << resouce
        end

        tr = nil
        doc.css("th").each do |th|
          if th.text == "関連ホームページ"
            tr = th.parent
            break
          end
        end
        if tr
          url = tr.css("td").text.strip
          if url.present? && url != "http://"
            dataset["resouces"] << {
              "filename" => "関連ホームページ",
              "source_url" => url
            }
            datasets << dataset
          end
        end

        rescue => e
          puts "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}"
        end
      end
    end

    csv = CSV.generate do |data|
      data << %w(dataset_no url filename name text resouce_name resouce_text resouce_url resouce_source_url format area license)

      datasets.each_with_index do |dataset, d_idx|

        filename = "#{node.filename}/fuji-#{d_idx}.html"
        name = dataset["name"]
        text = dataset["text"]

        dataset["resouces"].each_with_index do |resouce, r_idx|

          resouce_filename = resouce["filename"]
          resouce_text = ""
          resouce_url = resouce["url"]
          resouce_source_url = resouce["source_url"]
          format = resouce["format"]
          area = dataset["area"]
          license = dataset["license"]

          line = []
          line << (d_idx + 1)
          line << dataset["url"]
          line << filename
          line << name
          line << text
          line << resouce_filename
          line << resouce_text
          line << resouce_url
          line << resouce_source_url
          line << format
          line << area
          line << license

          data << line
        end
      end
    end

    open("export_fuji.csv", "w").write(csv)
  end

  task import_fuji_csv: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    puts "Please input node: node=[node]" or exit if ENV['node'].blank?
    puts "Please input node: path=[export_fuji.csv]" or exit if ENV['path'].blank?

    site = ::Cms::Site.where(host: ENV['site']).first
    node = ::Opendata::Node::Dataset.site(site).where(id: ENV['node']).first
    path = ENV['path']

    datasets = {}
    groups = {}
    areas = {}

    SS::Group.each do |group|
      groups[group.trailing_name] = group
    end

    Opendata::Node::Area.site(site).each do |area|
      areas[area.name] = area
    end

    table = CSV.read(path, headers: true)

    puts table.size

    table.each_with_index do |row, idx|
      dataset = Opendata::Dataset.site(site).where(filename: row["filename"]).first
      dataset ||= Opendata::Dataset.new

      dataset.cur_site = site
      dataset.cur_node = node
      dataset.layout = node.page_layout || node.layout

      dataset.name = row["name"]
      dataset.filename = row["filename"]
      dataset.text = row["text"]

      group = row["area"]
      group = "民間・学校・その他" if group == "民間データ"
      dataset.group_ids = [groups[group].id]

      area = areas[row["area"]]
      dataset.area_ids = [area.id] if area

      # dataset.created = row["created"]
      # dataset.updated = row["updated"]
      # dataset.released = row["updated"]

      dataset.save!

      resource = Opendata::Resource.new

      if row["resouce_source_url"].present?
        # set source url
        resource.source_url = row["resouce_source_url"]
        resource.format = "html"
      else
        # download file from url
        in_file = open("https://open-data.pref.shizuoka.jp" + row["resouce_url"])
        in_file.instance_variable_set(:@_original_filename, row["resouce_name"])
        def in_file.original_filename
          @_original_filename
        end

        ss_file = SS::File.new
        ss_file.in_file = in_file
        ss_file.model = "opendata/resource"
        ss_file.state = "public"
        ss_file.site_id = site.id
        ss_file.save!

        sleep 1

        resource.file_id = ss_file.id
        resource.format = row["format"]
      end

      resource.name = row["resouce_name"]
      resource.filename = row["resouce_name"]

      if row["license"] == "ライセンス（クリエイティブ・コモンズ表示）"
        resource.license = Opendata::License.site(site).where(name: "表示（CC BY）").first
      end

      # resource.created = row["resource_created"]
      # resource.updated = row["resource_updated"]
      # resource.released = row["resource_updated"]

      dataset.resources << resource
      resource.save!

      puts "#{idx} #{dataset.name} #{resource.filename}"
    end
  end
end
