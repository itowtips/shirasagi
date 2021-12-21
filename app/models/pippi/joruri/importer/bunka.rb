module Pippi::Joruri::Importer
  class Bunka < Base
    attr_reader :user, :group, :default_node, :special_node, :upload_files_path

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @default_node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "文化教養：文化教養施設")
      @special_node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "文化教養：施設特別バージョン")
      @upload_files_path = "joruri_files/bunka"
    end

    def import_map_bunka
      csv = CSV.open("import_seminers_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "map/bunka.csv")
      circle_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      circle_csv.each_with_index do |row, idx|
        type = row["ページタイプ"]
        title = row["施設名称"]
        kana = row["カナ"]
        image = row["top画像"]
        area1 = row["区"]
        area2 = row["地区"]
        postal_code = row["郵便番号"]
        address = row["所在地"]
        lat = row["緯度"]
        lon = row["経度"]
        tel = row["電話"]
        url = row["URL"]
        closing_day = row["休館日"]
        opening_hours = row["開館時間"]
        cost = row["料金"]
        access = row["アクセス"]
        parking = row["駐車場"]
        code = row["市区町村コード"]
        no = row["NO"]
        summary = row["施設概要"]

        osusume1_title = row["おすすめ１タイトル"]
        osusume1_image = row["おすすめ１画像"]
        osusume1_explanation = row["おすすめ１説明"]
        osusume1_target = []
        osusume1_target << "赤ちゃん" if row["おすすめ1 ターゲット[赤ちゃん]"] == "1"
        osusume1_target << "幼児" if row["おすすめ1 ターゲット[幼児]"] == "1"
        osusume1_target << "小学生" if row["おすすめ1 ターゲット[小学生]"] == "1"

        osusume2_title = row["おすすめ２タイトル"]
        osusume2_image = row["おすすめ２画像"]
        osusume2_explanation = row["おすすめ２説明"]
        osusume2_target = []
        osusume2_target << "赤ちゃん" if row["おすすめ2 ターゲット[赤ちゃん]"] == "1"
        osusume2_target << "幼児" if row["おすすめ2 ターゲット[幼児]"] == "1"
        osusume2_target << "小学生" if row["おすすめ2 ターゲット[小学生]"] == "1"

        osusume3_title = row["おすすめ３タイトル"]
        osusume3_image = row["おすすめ３画像"]
        osusume3_explanation = row["おすすめ３説明"]
        osusume3_target = []
        osusume3_target << "赤ちゃん" if row["おすすめ3 ターゲット[赤ちゃん]"] == "1"
        osusume3_target << "幼児" if row["おすすめ3 ターゲット[幼児]"] == "1"
        osusume3_target << "小学生" if row["おすすめ3 ターゲット[小学生]"] == "1"

        kodure_target = []
        kodure_target << "授乳室" if row["子連れに便利な施設[授乳室]"] == "1"
        kodure_target << "オムツ交換台" if row["子連れに便利な施設[オムツ交換台]"] == "1"
        kodure_target << "ベビーカーOK" if row["子連れに便利な施設[ベビーカーOK]"] == "1"
        kodure_target << "託児サービス" if row["子連れに便利な施設[託児サービス]"] == "1"
        kodure_target << "飲食持参OK" if row["子連れに便利な施設[飲食持参OK]"] == "1"
        kodure_target << "自販機・売店" if row["子連れに便利な施設[自販機・売店]"] == "1"
        kodure_target << "レストラン" if row["子連れに便利な施設[レストラン]"] == "1"

        kodure_remark = row["子連れ便利度補足"]
        advice = row["取材ママ（パパ）のアドバイス"]

        interview_date = row["調査日："]
        interviewer = row["取材："]

        original_id = row["joruri_id"]
        original_url = row["joruri_url"]

        rel_Joruri = Pippi::Joruri::Relation::Bunka.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Bunka.new
        end

        item.cur_site = site
        item.cur_user = user
        item.name = title
        item.group_ids = [group.id]

        if image.present?
          filename = ::File.basename(image)
          path = ::File.join(upload_files_path, filename)
          raise "not found joruri file!" if !::File.exists?(path)

          image = SS::File.new
          image.in_file = Fs::UploadedFile.create_from_file(path)
          image.site = site
          image.user = user
          image.filename = filename
          image.model = item.class.name
          image.save!
          image.set(content_type: ::Fs.content_type(filename))
        end

        if osusume1_image.present?
          filename = ::File.basename(osusume1_image)
          path = ::File.join(upload_files_path, filename)
          raise "not found joruri file!" if !::File.exists?(path)

          osusume1_image = SS::File.new
          osusume1_image.in_file = Fs::UploadedFile.create_from_file(path)
          osusume1_image.site = site
          osusume1_image.user = user
          osusume1_image.filename = filename
          osusume1_image.model = item.class.name
          osusume1_image.save!
          osusume1_image.set(content_type: ::Fs.content_type(filename))
        end

        if osusume2_image.present?
          filename = ::File.basename(osusume2_image)
          path = ::File.join(upload_files_path, filename)
          raise "not found joruri file!" if !::File.exists?(path)

          osusume2_image = SS::File.new
          osusume2_image.in_file = Fs::UploadedFile.create_from_file(path)
          osusume2_image.site = site
          osusume2_image.user = user
          osusume2_image.filename = filename
          osusume2_image.model = item.class.name
          osusume2_image.save!
          osusume2_image.set(content_type: ::Fs.content_type(filename))
        end

        if osusume3_image.present?
          filename = ::File.basename(osusume3_image)
          path = ::File.join(upload_files_path, filename)
          raise "not found joruri file!" if !::File.exists?(path)

          osusume3_image = SS::File.new
          osusume3_image.in_file = Fs::UploadedFile.create_from_file(path)
          osusume3_image.site = site
          osusume3_image.user = user
          osusume3_image.filename = filename
          osusume3_image.model = item.class.name
          osusume3_image.save!
          osusume3_image.set(content_type: ::Fs.content_type(filename))
        end

        if type == "施設特別バージョン"
          node = special_node
          layout = node.page_layout
          form = node.st_form_default

          item.cur_node = node
          item.form = form
          item.layout = layout
          column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
          column_values[0].value = kana
          column_values[1].file_id = image.id if image.present?
          column_values[2].value = area1
          column_values[3].value = area2
          column_values[4].value = postal_code
          column_values[5].value = address
          column_values[6].value = tel
          column_values[7].link_label = url
          column_values[7].link_url = url
          column_values[8].value = closing_day
          column_values[9].value = opening_hours
          column_values[10].value = cost
          column_values[11].value = access
          column_values[12].value = parking
          column_values[13].value = code
          column_values[14].value = no
          column_values[15].value = summary

          column_values[16].value = osusume1_title
          column_values[17].file_id = osusume1_image.id if osusume1_image.present?
          column_values[18].value = osusume1_explanation
          column_values[19].values = osusume1_target

          column_values[20].value = osusume2_title
          column_values[21].file_id = osusume2_image.id if osusume2_image.present?
          column_values[22].value = osusume2_explanation
          column_values[23].values = osusume2_target

          column_values[24].value = osusume3_title
          column_values[25].file_id = osusume3_image.id if osusume3_image.present?
          column_values[26].value = osusume3_explanation
          column_values[27].values = osusume3_target

          column_values[28].values = kodure_target
          column_values[29].value = kodure_remark
          column_values[30].value = advice
          column_values[31].value = interview_date
          column_values[32].value = interviewer
        else
          node = default_node
          layout = node.page_layout
          form = node.st_form_default

          item.cur_node = node
          item.form = form
          item.layout = layout
          column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
          column_values[0].value = kana
          column_values[1].file_id = image.id if image.present?
          column_values[2].value = area1
          column_values[3].value = area2
          column_values[4].value = postal_code
          column_values[5].value = address
          column_values[6].value = tel
          column_values[7].link_label = url
          column_values[7].link_url = url
          column_values[8].value = closing_day
          column_values[9].value = cost
          column_values[10].value = access
          column_values[11].value = parking
          column_values[12].value = code
          column_values[13].value = no
        end

        item.column_values = column_values
        item.map_points = [{ name: "", loc: [lon, lat], text: "" }]
        def item.set_updated; end
        puts "#{idx}.[#{node.name}] #{item.name}"
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, type, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def destroy_map_bunka
      Pippi::Joruri::Relation::Bunka.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
