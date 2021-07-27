namespace :pippi do
  namespace :facility do
    task :create_facility_nodes, [:site] => :environment do |task, args|
      ::Tasks::Cms::Base.with_site(args[:site] || ENV['site']) do |site|

        @site = site
        @user = SS::User.find_by(uid: "sys")
        @layout = Cms::Layout.site(@site).find_by(name: "施設ガイド")

        def save_node(data)
          puts data[:name]
          cond = { site_id: @site.id, filename: data[:filename], route: data[:route] }

          item = data[:route].sub("/", "/node/").camelize.constantize.unscoped.find_or_initialize_by(cond)
          item.attributes = data
          item.cur_user = @user
          item.save
          item.add_to_set group_ids: @site.group_ids

          item
        end

        save_node route: "facility/search", filename: "map", name: "子育てマップ", layout_id: @layout.id
        save_node route: "facility/node", filename: "map/list", name: "施設一覧", layout_id: @layout.id
        save_node route: "cms/node", filename: "map/category", name: "分類", layout_id: @layout.id
        save_node route: "cms/node", filename: "map/area", name: "地域", layout_id: @layout.id

        # facility/category
        save_node route: "facility/category", filename: "map/category/category1", name: "認定こども園", layout_id: @layout.id, order: 100
        save_node route: "facility/category", filename: "map/category/category1/sub1", name: "認定こども園（保育所機能）", layout_id: @layout.id, order: 110
        save_node route: "facility/category", filename: "map/category/category1/sub2", name: "認定こども園（幼稚園機能）", layout_id: @layout.id, order: 120

        save_node route: "facility/category", filename: "map/category/category2", name: "保育園", layout_id: @layout.id, order: 200
        save_node route: "facility/category", filename: "map/category/category2/sub1", name: "公立認可保育園", layout_id: @layout.id, order: 210
        save_node route: "facility/category", filename: "map/category/category2/sub2", name: "私立認可保育園", layout_id: @layout.id, order: 220

        save_node route: "facility/category", filename: "map/category/category3", name: "地域型保育事業", layout_id: @layout.id, order: 300
        save_node route: "facility/category", filename: "map/category/category3/sub1", name: "小規模保育事業", layout_id: @layout.id, order: 310
        save_node route: "facility/category", filename: "map/category/category3/sub2", name: "事業所内保育事業", layout_id: @layout.id, order: 320

        save_node route: "facility/category", filename: "map/category/category4", name: "認証保育所", layout_id: @layout.id, order: 400
        save_node route: "facility/category", filename: "map/category/category4/sub1", name: "Ⅰ類", layout_id: @layout.id, order: 410
        save_node route: "facility/category", filename: "map/category/category4/sub2", name: "Ⅱ類", layout_id: @layout.id, order: 420

        save_node route: "facility/category", filename: "map/category/category5", name: "認可外保育施設", layout_id: @layout.id, order: 500
        save_node route: "facility/category", filename: "map/category/category5/sub1", name: "認可外", layout_id: @layout.id, order: 510
        save_node route: "facility/category", filename: "map/category/category5/sub2", name: "企業主導型保育事業", layout_id: @layout.id, order: 520
        save_node route: "facility/category", filename: "map/category/category5/sub3", name: "外国人向け", layout_id: @layout.id, order: 530

        save_node route: "facility/category", filename: "map/category/category6", name: "幼稚園", layout_id: @layout.id, order: 600
        save_node route: "facility/category", filename: "map/category/category6/sub1", name: "公立幼稚園", layout_id: @layout.id, order: 610
        save_node route: "facility/category", filename: "map/category/category6/sub2", name: "私立幼稚園", layout_id: @layout.id, order: 620
        save_node route: "facility/category", filename: "map/category/category6/sub3", name: "私立幼稚園（従来型）", layout_id: @layout.id, order: 630

        save_node route: "facility/category", filename: "map/category/category7", name: "小学校", layout_id: @layout.id, order: 700
        save_node route: "facility/category", filename: "map/category/category7/sub1", name: "浜松市立", layout_id: @layout.id, order: 710
        save_node route: "facility/category", filename: "map/category/category7/sub2", name: "国立", layout_id: @layout.id, order: 720
        save_node route: "facility/category", filename: "map/category/category7/sub3", name: "私立", layout_id: @layout.id, order: 730

        save_node route: "facility/category", filename: "map/category/category8", name: "病児・病後児保育", layout_id: @layout.id, order: 800
        save_node route: "facility/category", filename: "map/category/category8/sub1", name: "浜松市委託事業", layout_id: @layout.id, order: 810
        save_node route: "facility/category", filename: "map/category/category8/sub2", name: "その他の民間", layout_id: @layout.id, order: 820

        save_node route: "facility/category", filename: "map/category/category9", name: "特別支援学校", layout_id: @layout.id, order: 900
        save_node route: "facility/category", filename: "map/category/category9/sub1", name: "病児・病後児保育", layout_id: @layout.id, order: 910

        save_node route: "facility/category", filename: "map/category/category10", name: "児童館", layout_id: @layout.id, order: 1000
        save_node route: "facility/category", filename: "map/category/category10/sub1", name: "児童館", layout_id: @layout.id, order: 1010

        save_node route: "facility/category", filename: "map/category/category11", name: "学童保育", layout_id: @layout.id, order: 1100
        save_node route: "facility/category", filename: "map/category/category11/sub1", name: "放課後児童会", layout_id: @layout.id, order: 1110
        save_node route: "facility/category", filename: "map/category/category11/sub2", name: "民間放課後児童クラブ", layout_id: @layout.id, order: 1120
        save_node route: "facility/category", filename: "map/category/category11/sub3", name: "類似放課後児童クラブ", layout_id: @layout.id, order: 1130
        save_node route: "facility/category", filename: "map/category/category11/sub4", name: "その他の民間学童保育", layout_id: @layout.id, order: 1140

        save_node route: "facility/category", filename: "map/category/category12", name: "ひろば", layout_id: @layout.id, order: 1200
        save_node route: "facility/category", filename: "map/category/category12/sub1", name: "子育て支援ひろば", layout_id: @layout.id, order: 1210
        save_node route: "facility/category", filename: "map/category/category12/sub2", name: "親子ひろば", layout_id: @layout.id, order: 1220
        save_node route: "facility/category", filename: "map/category/category12/sub3", name: "中山間地域親子ひろば", layout_id: @layout.id, order: 1230

        save_node route: "facility/category", filename: "map/category/category13", name: "公共施設", layout_id: @layout.id, order: 1300
        save_node route: "facility/category", filename: "map/category/category13/sub1", name: "子どもと行ける公共施設", layout_id: @layout.id, order: 1310
        save_node route: "facility/category", filename: "map/category/category13/sub2", name: "プール", layout_id: @layout.id, order: 1320

        save_node route: "facility/category", filename: "map/category/category14", name: "公園", layout_id: @layout.id, order: 1400
        save_node route: "facility/category", filename: "map/category/category14/sub1", name: "人気の公園", layout_id: @layout.id, order: 1410

        save_node route: "facility/category", filename: "map/category/category15", name: "子ども食堂", layout_id: @layout.id, order: 1420
        save_node route: "facility/category", filename: "map/category/category15/sub1", name: "子ども食堂", layout_id: @layout.id, order: 1430

        save_node route: "facility/category", filename: "map/category/category16", name: "学習支援", layout_id: @layout.id, order: 1500
        save_node route: "facility/category", filename: "map/category/category16/sub1", name: "はままつ子どもの学習教室", layout_id: @layout.id, order: 1510
        save_node route: "facility/category", filename: "map/category/category16/sub2", name: "その他の民間学習支援", layout_id: @layout.id, order: 1520

        save_node route: "facility/category", filename: "map/category/category17", name: "その他", layout_id: @layout.id, order: 1600
        save_node route: "facility/category", filename: "map/category/category17/sub1", name: "オンライン", layout_id: @layout.id, order: 1610

        # facility/location
        save_node route: "facility/location", filename: "map/area/area1", name: "中区", layout_id: @layout.id, order: 100
        save_node route: "facility/location", filename: "map/area/area1/sub1", name: "中央", layout_id: @layout.id, order: 105
        save_node route: "facility/location", filename: "map/area/area1/sub2", name: "西", layout_id: @layout.id, order: 110
        save_node route: "facility/location", filename: "map/area/area1/sub3", name: "城北", layout_id: @layout.id, order: 115
        save_node route: "facility/location", filename: "map/area/area1/sub4", name: "北", layout_id: @layout.id, order: 120
        save_node route: "facility/location", filename: "map/area/area1/sub5", name: "アクト", layout_id: @layout.id, order: 125
        save_node route: "facility/location", filename: "map/area/area1/sub6", name: "駅南", layout_id: @layout.id, order: 130
        save_node route: "facility/location", filename: "map/area/area1/sub7", name: "県居", layout_id: @layout.id, order: 135
        save_node route: "facility/location", filename: "map/area/area1/sub8", name: "佐鳴台", layout_id: @layout.id, order: 145
        save_node route: "facility/location", filename: "map/area/area1/sub9", name: "富塚", layout_id: @layout.id, order: 150
        save_node route: "facility/location", filename: "map/area/area1/sub10", name: "萩丘", layout_id: @layout.id, order: 155
        save_node route: "facility/location", filename: "map/area/area1/sub11", name: "曳馬", layout_id: @layout.id, order: 160
        save_node route: "facility/location", filename: "map/area/area1/sub12", name: "江東", layout_id: @layout.id, order: 175
        save_node route: "facility/location", filename: "map/area/area1/sub13", name: "江西", layout_id: @layout.id, order: 180
        save_node route: "facility/location", filename: "map/area/area1/sub14", name: "花川", layout_id: @layout.id, order: 185

        save_node route: "facility/location", filename: "map/area/area2", name: "東区", layout_id: @layout.id, order: 200
        save_node route: "facility/location", filename: "map/area/area2/sub1", name: "積志", layout_id: @layout.id, order: 205
        save_node route: "facility/location", filename: "map/area/area2/sub2", name: "長上", layout_id: @layout.id, order: 210
        save_node route: "facility/location", filename: "map/area/area2/sub3", name: "笠井", layout_id: @layout.id, order: 215
        save_node route: "facility/location", filename: "map/area/area2/sub4", name: "中ノ町", layout_id: @layout.id, order: 220
        save_node route: "facility/location", filename: "map/area/area2/sub5", name: "和田", layout_id: @layout.id, order: 225
        save_node route: "facility/location", filename: "map/area/area2/sub6", name: "蒲", layout_id: @layout.id, order: 230

        save_node route: "facility/location", filename: "map/area/area3", name: "西区", layout_id: @layout.id, order: 300
        save_node route: "facility/location", filename: "map/area/area3/sub1", name: "入野", layout_id: @layout.id, order: 305
        save_node route: "facility/location", filename: "map/area/area3/sub2", name: "篠原", layout_id: @layout.id, order: 310
        save_node route: "facility/location", filename: "map/area/area3/sub3", name: "庄内", layout_id: @layout.id, order: 315
        save_node route: "facility/location", filename: "map/area/area3/sub4", name: "和地", layout_id: @layout.id, order: 320
        save_node route: "facility/location", filename: "map/area/area3/sub5", name: "伊佐見", layout_id: @layout.id, order: 325
        save_node route: "facility/location", filename: "map/area/area3/sub6", name: "神久呂", layout_id: @layout.id, order: 330
        save_node route: "facility/location", filename: "map/area/area3/sub7", name: "舞阪", layout_id: @layout.id, order: 335
        save_node route: "facility/location", filename: "map/area/area3/sub8", name: "雄踏", layout_id: @layout.id, order: 340

        save_node route: "facility/location", filename: "map/area/area4", name: "南区", layout_id: @layout.id, order: 400
        save_node route: "facility/location", filename: "map/area/area4/sub1", name: "白脇", layout_id: @layout.id, order: 405
        save_node route: "facility/location", filename: "map/area/area4/sub2", name: "新津", layout_id: @layout.id, order: 410
        save_node route: "facility/location", filename: "map/area/area4/sub3", name: "飯田", layout_id: @layout.id, order: 415
        save_node route: "facility/location", filename: "map/area/area4/sub4", name: "芳川", layout_id: @layout.id, order: 420
        save_node route: "facility/location", filename: "map/area/area4/sub5", name: "河輪", layout_id: @layout.id, order: 425
        save_node route: "facility/location", filename: "map/area/area4/sub6", name: "五島", layout_id: @layout.id, order: 430
        save_node route: "facility/location", filename: "map/area/area4/sub7", name: "可美", layout_id: @layout.id, order: 435

        save_node route: "facility/location", filename: "map/area/area5", name: "北区", layout_id: @layout.id, order: 500
        save_node route: "facility/location", filename: "map/area/area5/sub1", name: "都田", layout_id: @layout.id, order: 505
        save_node route: "facility/location", filename: "map/area/area5/sub2", name: "新都田", layout_id: @layout.id, order: 510
        save_node route: "facility/location", filename: "map/area/area5/sub3", name: "三方原", layout_id: @layout.id, order: 515
        save_node route: "facility/location", filename: "map/area/area5/sub4", name: "細江", layout_id: @layout.id, order: 520
        save_node route: "facility/location", filename: "map/area/area5/sub5", name: "引佐", layout_id: @layout.id, order: 525
        save_node route: "facility/location", filename: "map/area/area5/sub6", name: "三ヶ日", layout_id: @layout.id, order: 530

        save_node route: "facility/location", filename: "map/area/area6", name: "浜北区", layout_id: @layout.id, order: 600
        save_node route: "facility/location", filename: "map/area/area6/sub1", name: "浜名", layout_id: @layout.id, order: 605
        save_node route: "facility/location", filename: "map/area/area6/sub2", name: "北浜", layout_id: @layout.id, order: 610
        save_node route: "facility/location", filename: "map/area/area6/sub3", name: "中瀬", layout_id: @layout.id, order: 615
        save_node route: "facility/location", filename: "map/area/area6/sub4", name: "赤佐", layout_id: @layout.id, order: 620
        save_node route: "facility/location", filename: "map/area/area6/sub5", name: "麁玉", layout_id: @layout.id, order: 625

        save_node route: "facility/location", filename: "map/area/area7", name: "天竜区", layout_id: @layout.id, order: 700
        save_node route: "facility/location", filename: "map/area/area7/sub1", name: "天竜", layout_id: @layout.id, order: 705
        save_node route: "facility/location", filename: "map/area/area7/sub2", name: "春野", layout_id: @layout.id, order: 710
        save_node route: "facility/location", filename: "map/area/area7/sub3", name: "佐久間", layout_id: @layout.id, order: 715
        save_node route: "facility/location", filename: "map/area/area7/sub4", name: "水窪", layout_id: @layout.id, order: 720
        save_node route: "facility/location", filename: "map/area/area7/sub5", name: "龍山", layout_id: @layout.id, order: 725

        save_node route: "facility/location", filename: "map/area/area8", name: "その他", layout_id: @layout.id, order: 800
        save_node route: "facility/location", filename: "map/area/area8/sub1", name: "その他", layout_id: @layout.id, order: 805
      end
    end

    task :create_facility_pages, [:site] => :environment do |task, args|
      ::Tasks::Cms::Base.with_site(args[:site] || ENV['site']) do |site|

        @site = site
        @user = SS::User.find_by(uid: "sys")
        @layout = Cms::Layout.site(@site).find_by(name: "施設ガイド")

        @categories = Facility::Node::Category.site(@site).where(filename: /^map\/category\//).map do |item|
          [item.name, item]
        end.to_h
        @locations = Facility::Node::Location.site(@site).where(filename: /^map\/area\//).map do |item|
          [item.name, item]
        end.to_h

        def save_node(data)
          puts data[:name]
          cond = { site_id: @site.id, filename: data[:filename], route: data[:route] }

          item = data[:route].sub("/", "/node/").camelize.constantize.unscoped.find_or_initialize_by(cond)
          item.attributes = data
          item.cur_user = @user
          item.save
          item.add_to_set group_ids: @site.group_ids

          item
        end

        def save_page(data)
          puts data[:name]
          cond = { site_id: @site._id, filename: data[:filename] }

          route = data[:route].presence || 'cms/page'
          item = route.camelize.constantize.find_or_initialize_by(cond)

          item.attributes = data
          item.cur_user = @user
          item.save
          item.add_to_set group_ids: @site.group_ids

          item
        end

        path = ::File.join(Rails.root, "lib/tasks/pippi/facility/child_facility.csv")
        csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
        csv.each_with_index do |row, idx|
          basename = row["name"]
          name = row["title"]
          place = row["place"]
          division = row["division"]
          category = row["category"]
          lat = row["lat"]
          lng = row["lng"]
          url = row["url"]
          fax = row["fax"]

          category = @categories[category]
          location = @locations[division]
          if !(category && location && category.parent && location.parent)
            puts "skip #{row["title"]}"
            next
          end

          additional_info = []
          1.upto(22) do |i|
            kv = row["add#{i}"]
            next if kv.blank?

            k, v = kv.split("$$")
            additional_info << OpenStruct.new(field: k, value: v)
          end

          node = save_node route: "facility/page", filename: "map/list/item#{idx}",
            name: name, layout_id: @layout.id,
            address: place, related_url: url, fax: fax,
            category_ids: [category.id, category.parent.id],
            location_ids: [location.id, location.parent.id],
            additional_info: additional_info

          save_page route: "facility/map", filename: "#{node.filename}/map.html", name: "地図",
            layout_id: @layout.id, map_points: [{ name: name, loc: [lng, lat], text: "" }]
        end
      end
    end
  end
end
