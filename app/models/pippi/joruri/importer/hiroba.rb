module Pippi::Joruri::Importer
  class Hiroba < Base
    attr_reader :user, :group, :kosodate_node, :oyako_node, :sankan_node

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")

      @kosodate_node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "子育て支援ひろば")
      @oyako_node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "親子ひろば")
      @sankan_node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "中山間地域親子ひろば")
    end

    def import_map_hiroba
      csv = CSV.open("import_hiroba_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "map/hiroba/kosodate.csv")
      import_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      import_csv.each_with_index do |row, idx|
        node = kosodate_node
        title = row["施設名"]
        area1 = row["大_区・地域"]
        area2 = row["小_区・地域"]
        address = row["所在地_住所"]
        tel = row["電話"]
        hitokoto = row["ひと言"]
        url = row["URL"]
        date = row["開催日"]
        business_hours = row["開催時間"]
        parking = row["駐車場"]
        support = row["プラスサポート"]
        detail = row["出張ひろば詳細"]
        manager = row["運営者"]
        flyer = row["今月のチラシ"]
        state = (row["状態"] == "非公開") ? "closed" : "public"
        lat, lon = row["所在地_緯度経度"].split(",")
        created = row["作成日時"]
        updated = row["更新日時"]
        original_id = row["ID"]
        original_url = row["公開画面URL"]

        rel_Joruri = Pippi::Joruri::Relation::Hiroba.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Hiroba.new
        end

        layout = node.page_layout
        form = node.st_form_default

        # save article
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.name = title
        item.form = form
        item.layout = layout
        item.group_ids = [group.id]
        item.state = state

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[1].value = area1
        column_values[2].value = area2
        column_values[3].value = address
        #column_values[4].value = postal_code
        column_values[5].value = tel
        column_values[6].link_label = url
        column_values[6].link_url = url
        column_values[7].value = date
        column_values[8].value = business_hours
        column_values[9].value = parking
        if support.present?
          column_values[10].values = (support.split(/\n/) & column_values[10].column.select_options)
        end
        column_values[11].value = detail
        column_values[12].value = manager
        column_values[13].value = hitokoto

        item.form = form
        item.column_values = column_values
        item.map_points = [{ name: "", loc: [lon, lat], text: "" }]
        puts "#{idx}. #{item.name}"

        item.created = created
        item.updated = updated
        item.released_type = "fixed"
        item.released = updated
        item.first_released = updated
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_id = original_id
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url]
        csv.flush
      end

      path = ::File.join(csv_path, "map/hiroba/oyako.csv")
      import_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      import_csv.each_with_index do |row, idx|
        node = oyako_node
        title = row["施設名"]
        area1 = row["大_区・地域"]
        area2 = row["小_区・地域"]
        address = row["所在地_住所"]
        tel = row["電話"]
        hitokoto = row["ひと言"]
        url = row["URL"]
        date = row["開催日"]
        business_hours = row["開催時間"]
        park = row["園庭開放"]
        parking = row["駐車場"]
        state = (row["状態"] == "非公開") ? "closed" : "public"
        lat, lon = row["所在地_緯度経度"].split(",")
        created = row["作成日時"]
        updated = row["更新日時"]
        original_id = row["ID"]
        original_url = row["公開画面URL"]

        rel_Joruri = Pippi::Joruri::Relation::Hiroba.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Hiroba.new
        end

        layout = node.page_layout
        form = node.st_form_default

        # save article
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.name = title
        item.form = form
        item.layout = layout
        item.group_ids = [group.id]
        item.state = state

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[1].value = area1
        column_values[2].value = area2
        column_values[3].value = address
        #column_values[4].value = postal_code
        column_values[5].value = tel
        column_values[6].link_label = url
        column_values[6].link_url = url
        column_values[7].value = date
        column_values[8].value = business_hours
        column_values[9].value = park
        column_values[10].value = parking
        column_values[11].value = hitokoto

        item.form = form
        item.column_values = column_values
        item.map_points = [{ name: "", loc: [lon, lat], text: "" }]
        puts "#{idx}. #{item.name}"

        item.created = created
        item.updated = updated
        item.released_type = "fixed"
        item.released = updated
        item.first_released = updated
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_id = original_id
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url]
        csv.flush
      end

      path = ::File.join(csv_path, "map/hiroba/sankan.csv")
      import_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      import_csv.each_with_index do |row, idx|
        node = sankan_node
        title = row["施設名"]
        area1 = row["大_区・地域"]
        area2 = row["小_区・地域"]
        address = row["所在地_住所"]
        tel = row["電話"]
        hitokoto = row["ひと言"]
        date = row["開催日"]
        business_hours = row["開催時間"]
        parking = row["駐車場"]
        state = (row["状態"] == "非公開") ? "closed" : "public"
        lat, lon = row["所在地_緯度経度"].split(",")
        created = row["作成日時"]
        updated = row["更新日時"]
        original_id = row["ID"]
        original_url = row["公開画面URL"]

        rel_Joruri = Pippi::Joruri::Relation::Hiroba.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Hiroba.new
        end

        layout = node.page_layout
        form = node.st_form_default

        # save article
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.name = title
        item.form = form
        item.layout = layout
        item.group_ids = [group.id]
        item.state = state

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[1].value = area1
        column_values[2].value = area2
        column_values[3].value = address
        #column_values[4].value = postal_code
        column_values[5].value = tel
        column_values[6].value = date
        column_values[7].value = business_hours
        column_values[8].value = parking
        column_values[9].value = hitokoto

        item.form = form
        item.column_values = column_values
        item.map_points = [{ name: "", loc: [lon, lat], text: "" }]
        puts "#{idx}. #{item.name}"

        item.created = created
        item.updated = updated
        item.released_type = "fixed"
        item.released = updated
        item.first_released = updated
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_id = original_id
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url]
        csv.flush
      end
    end

    def destroy_map_hiroba
      Pippi::Joruri::Relation::Hiroba.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
