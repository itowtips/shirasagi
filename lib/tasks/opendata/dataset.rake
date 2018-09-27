namespace :opendata do

  task notify_dataset_update_plan: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    site = ::Cms::Site.where(host: ENV['site']).first
    ::Opendata::NotifyUpdatePlanJob.bind(site_id: site.id).perform_now
  end

  task harvest_datasets: :environment do
    puts "Please input site: site=[www]" or exit if ENV['site'].blank?

    site = ::Cms::Site.where(host: ENV['site']).first
    ::Opendata::HarvestDatasetsJob.bind(site_id: site.id).perform_now(
      importer_id: ENV['importer'],
      exporter_id: ENV['exporter']
    )
  end

  namespace :harvest do
    task exporter_dataset_purge: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.dataset_purge
    end

    task exporter_group_list: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.group_list
    end

    task exporter_organization_list: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.organization_list
    end

    task exporter_initialize_organization: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.initialize_organization
    end

    task exporter_initialize_group: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      puts "Please input exporter: exporter=[1]" or exit if ENV['exporter'].blank?

      site = ::Cms::Site.where(host: ENV['site']).first
      exporter = Opendata::Harvest::Exporter.site(site).where(id: ENV['exporter']).first
      exporter.initialize_group
    end

  end

  task szod_sample: :environment do
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

    #names.each_with_index do |name, idx|
    #  filename = ::File.join("bunya", filenames[idx])
    #
    #  item = ::Opendata::Node::Category.new
    #  item.name = name
    #  item.filename = filename
    #  item.cur_site = site
    #
    #  puts "#{name} #{filename}"
    #  item.save!
    #end

    estat_names.each_with_index do |name, idx|
      filename = estat_filenames[idx]

      item = ::Opendata::Node::EstatCategory.new
      item.name = name
      item.filename = filename
      item.cur_site = site

      puts "#{name} #{filename}"
      item.save!
    end

  end

  task import_szod: :environment do
    #puts "Please input site: site=[www]" or exit if ENV['site'].blank?
    #puts "Please input node: node=[node]" or exit if ENV['node'].blank?

    #site = ::Cms::Site.where(host: ENV['site']).first
    #node = ::Opendata::Node::Dataset.where(id: ENV['node']).first
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
        dataset["name"] = tr.css("td").text

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
          resouce["url"] = a_tag.attributes["href"].value
          resouce["filename"] = a_tag.text
          resouce["format"] =  ::File.extname(a_tag.text).delete(".")
          dataset["resouces"] << resouce
        end

        datasets << dataset
        rescue => e
          puts "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}"
        end
      end
    end

    csv = CSV.generate do |data|
      data << %w(No 区分 データセット名 データセットURL リソース名 リソースURL フォーマット サイズ（ラベル） サイズ)
      datasets.each_with_index do |dataset, idx|
        dataset["resouces"].each do |resouce|
          line = []
          line << idx + 1
          line << dataset["area"]
          line << dataset["name"]
          line << dataset["url"]
          line << resouce["filename"]
          line << resouce["url"]
          line << resouce["format"]
          line << ""
          line << ""
          data << line
        end
      end
    end
    open("this.csv", "w").write(csv)


=begin
    data << %w(No データセット名 データセットURL リソース名 リソースURL フォーマット サイズ（ラベル） サイズ)

    size = 0
    datasets.each_with_index do |dataset, idx|
      dataset.resources.each do |resource|
        line = []
        line << idx + 1
        line << dataset.name
        line << dataset.display_url
        line << resource.name
        line << resource.url
        line << resource.format
        line << number_to_human_size(resource.size)
        line << resource.size
        data << line

        size += resource.size
      end
    end
=end
=begin
    def get_size_in_head(url)
      conn = ::Faraday::Connection.new(url: url)
      res = conn.head { |req| req.options.timeout = 10 }
      raise "Faraday conn.head timeout #{url}" unless res.success?

      headers = res.headers.map { |k, v| [k.downcase, v] }.to_h

      size = 0
      if headers["content-length"]
        size = headers["content-length"].to_i
      elsif headers["content-range"]
        size = headers["content-range"].scan(/\/(\d+)$/).flatten.first.to_i
      end

      size
    end
=end

  end

  task check_szod: :environment do

    ss_files = []

    table = ::CSV.table("that.csv", headers: true)

    puts "size #{table.size}"

    ::FileUtils.rm_rf("/Users/ito/Desktop/temp")

    table.each_with_index do |row, idx|
      name = row[2]
      dataset_url = row[3]
      filename = row[4]
      resource_url = row[5]
      format = row[6].to_s.downcase

      puts "#{idx + 1} #{filename}"

      if resource_url =~ /^\.\//
        url = dataset_url.sub(/\/[^\/]+?$/, "/") + resource_url.sub(/\.\//, "")

        file = open(url)
        file.instance_variable_set(:@_original_filename, filename)
        def file.original_filename
          @_original_filename
        end

        ss_file = SS::File.new
        ss_file.in_file = file
        ss_file.model = "opendata/resource"
        ss_file.state = "public"
        ss_file.save!

        ss_file.reload
        puts ss_file.size

        ::FileUtils.mkdir_p("/Users/ito/Desktop/temp")
        ::Fs.binwrite("/Users/ito/Desktop/temp/#{ss_file.id}_#{ss_file.filename}", ss_file.read)

        sleep 1

        ss_files << {
          resource_url: resource_url,
          id: ss_file.id
        }
=begin
        if format == "csv" || format == "txt"

          html = open(url).read

          require "nkf"
          text = NKF.nkf "-wLu", html

          file = Fs::UploadedFile.new
          file.write(text)
          file.original_filename = filename
          file.rewind

          ss_file = SS::File.new
          ss_file.in_file = file
          ss_file.model = "opendata/resource"
          ss_file.state = "public"
          ss_file.save!

          file.close

          puts "#{url} #{ss_file.id}"

          sleep 1

          ss_files << {
            resource_url: resource_url,
            id: ss_file.id
          }
        else
          ss_file = SS::StreamingFile.new
          ss_file.in_remote_url = url
          ss_file.model = "opendata/resource"
          ss_file.state = "public"
          ss_file.filename = filename
          #ss_file.site_id = site.id
          ss_file.save!

          puts "#{url} #{ss_file.id}"

          sleep 1

          ss_files << {
            resource_url: resource_url,
            id: ss_file.id
          }
        end
=end
      else
        ss_files << {}
      end
    end

    csv = CSV.generate do |data|
      data << %w(ID リソースURL サイズ（ラベル） サイズ)
      ss_files.each do |resource|

        line = []
        if resource.present?

          resource_url = resource[:resource_url]
          ss_file_id = resource[:id]

          ss_file = SS::File.find(ss_file_id)

          line << ss_file_id
          line << resource_url
          line << ActiveSupport::NumberHelper.number_to_human_size(ss_file.size)
          line << ss_file.size

        else

          line << ""
          line << ""
          line << ""
          line << ""

        end

        data << line
      end
    end
    open("sizeout.csv", "w").write(csv)

  end

end
