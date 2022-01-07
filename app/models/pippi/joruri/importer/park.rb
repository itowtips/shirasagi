module Pippi::Joruri::Importer
  class Park < Base
    attr_reader :user, :group, :node, :upload_files_path

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @node = Article::Node::Page.site(@site).find_by(filename: /^shisetsu\//, name: "公園レジャー")
      @upload_files_path = "joruri_files/park"
    end

    def create_image(filename)
      path = ::File.join(upload_files_path, filename)
      raise "not found joruri file! #{filename}" if !::File.exists?(path)

      image = SS::File.new
      image.in_file = Fs::UploadedFile.create_from_file(path)
      image.site = site
      image.user = user
      image.filename = filename
      image.model = "article/page"
      image.save!
      image.set(content_type: ::Fs.content_type(filename))
      image
    end

    def import_map_park
      csv = CSV.open("import_park_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "map/park.csv")
      circle_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      circle_csv.each_with_index do |row, idx|
        title = row["施設名称"]
        kana = row["カナ"]
        postal_code = row["郵便番号"]
        area1 = row["区"]
        area2 = row["地区"]
        address = row["所在地"]
        lat = row["緯度"]
        lon = row["経度"]
        tel = row["電話"]
        url = row["URL"]
        opening_hours = row["開園時間"]
        closing_day = row["休園日"]
        parking = row["駐車場"]
        no = row["NO"]
        code = row["市区町村コード"]
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
        kodure_target << "多目的トイレ" if row["子連れに便利な設備[多目的トイレ]"] == "1"
        kodure_target << "オムツ交換台" if row["子連れに便利な設備[オムツ交換台]"] == "1"
        kodure_target << "休憩所" if row["子連れに便利な設備[休憩所]"] == "1"
        kodure_target << "あずまや" if row["子連れに便利な設備[あずまや]"] == "1"
        kodure_target << "授乳室" if row["子連れに便利な設備[授乳室]"] == "1"
        kodure_target << "ベビーカー貸出" if row["子連れに便利な設備[ベビーカー貸出]"] == "1"
        kodure_target << "自販機・売店" if row["子連れに便利な設備[自販機・売店]"] == "1"
        kodure_target << "レストラン" if row["子連れに便利な設備[レストラン]"] == "1"

        kodure_remark = row["子連れ便利度補足"]
        playset = row["遊具"]
        usage = row["利用状況"]
        neighborhood = row["近隣の様子"]
        image = row["画像"]

        snap1_image = row["スナップ1 画像"]
        snap2_image = row["スナップ2 画像"]
        snap3_image = row["スナップ3 画像"]
        snap4_image = row["スナップ4 画像"]
        snap5_image = row["スナップ5 画像"]
        snap6_image = row["スナップ6 画像"]

        interview_date = row["調査日："]
        interviewer = row["取材："]

        original_id = row["joruri_id"]
        original_url = row["joruri_url"]

        rel_Joruri = Pippi::Joruri::Relation::Park.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Park.new
        end

        image = create_image(image) if image.present?
        osusume1_image = create_image(osusume1_image) if osusume1_image.present?
        osusume2_image = create_image(osusume2_image) if osusume2_image.present?
        osusume3_image = create_image(osusume3_image) if osusume3_image.present?
        snap1_image = create_image(snap1_image) if snap1_image.present?
        snap2_image = create_image(snap2_image) if snap2_image.present?
        snap3_image = create_image(snap3_image) if snap3_image.present?
        snap4_image = create_image(snap4_image) if snap4_image.present?
        snap5_image = create_image(snap5_image) if snap5_image.present?
        snap6_image = create_image(snap6_image) if snap6_image.present?

        layout = node.page_layout
        form = node.st_form_default

        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.name = title
        item.form = form
        item.layout = layout
        item.group_ids = [group.id]

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
        column_values[10].value = nil #cost
        column_values[11].value = nil #access
        column_values[12].value = parking
        column_values[13].value = code
        column_values[14].value = no
        column_values[15].value = summary

        column_values[16].value = osusume1_title
        if osusume1_image.present?
          column_values[17].file_id = osusume1_image.id
          column_values[17].image_html_type = "image"
        end
        column_values[18].value = osusume1_explanation
        column_values[19].values = osusume1_target

        column_values[20].value = osusume2_title
        if osusume2_image.present?
          column_values[21].file_id = osusume2_image.id
          column_values[21].image_html_type = "image"
        end
        column_values[22].value = osusume2_explanation
        column_values[23].values = osusume2_target

        column_values[24].value = osusume3_title
        if osusume3_image.present?
          column_values[25].file_id = osusume3_image.id
          column_values[25].image_html_type = "image"
        end
        column_values[26].value = osusume3_explanation
        column_values[27].values = osusume3_target

        column_values[28].values = kodure_target
        column_values[29].value = kodure_remark
        column_values[30].value = playset
        column_values[31].value = usage
        column_values[32].value = neighborhood

        if snap1_image.present?
          column_values[33].file_id = snap1_image.id
          column_values[33].image_html_type = "image"
        end
        if snap2_image.present?
          column_values[34].file_id = snap2_image.id
          column_values[34].image_html_type = "image"
        end
        if snap3_image.present?
          column_values[35].file_id = snap3_image.id
          column_values[35].image_html_type = "image"
        end
        if snap4_image.present?
          column_values[36].file_id = snap4_image.id
          column_values[36].image_html_type = "image"
        end
        if snap5_image.present?
          column_values[37].file_id = snap5_image.id
          column_values[37].image_html_type = "image"
        end
        if snap6_image.present?
          column_values[38].file_id = snap6_image.id
          column_values[38].image_html_type = "image"
        end

        column_values[39].value = interview_date
        column_values[40].value = interviewer

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

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def destroy_map_park
      Pippi::Joruri::Relation::Park.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
