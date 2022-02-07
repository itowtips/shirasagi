module Pippi::Joruri::Importer::Facility
  class KyokagaihoikuKigyosyudogatahoiku < Pippi::Joruri::Importer::Base
    attr_reader :groups, :kyokagaihoiku_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @kyokagaihoiku_nodes = {}
      %w(外国人向け認可外保育施設一覧 企業主導型保育事業所一覧 認可外保育施設一覧).each do |name|
        @kyokagaihoiku_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^shiritai\/yoho\/ninkagai\/kyokagaihoiku\//, name: name)
      end
    end

    def import_facility_kyokagaihoiku_kigyosyudogatahoiku_docs
      csv = CSV.open("import_facility_kyokagaihoiku_kigyosyudogatahoiku_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/kyokagaihoiku_kigyosyudogatahoiku.csv")
      kyokagaihoiku_kigyosyudogatahoiku_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '79'
        original_id = row["id"]
        published_at = row["published_at"]
        title = row["title"]
        created_at = row["created_at"]
        updated_at = row["updated_at"]
        body = row["body"]
        category = row["category_name"]
        group = row["creator_group_name"]
        user = row["creator_user_name"]
        state = row["state"]
        original_url = row["public_full_uri"]

        # node = kyokagaihoiku_nodes[category]
        node = kyokagaihoiku_nodes['企業主導型保育事業所一覧']
        # category = kyokagaihoiku_nodes[category]
        category = kyokagaihoiku_nodes['企業主導型保育事業所一覧']
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::KyokagaihoikuKigyosyudogatahoiku.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::KyokagaihoikuKigyosyudogatahoiku.new
        end

        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.layout = layout
        item.form = form
        item.group_ids = [group.id]
        item.name = title
        item.created = created_at
        item.updated = updated_at

        if published_at.present?
          item.released_type = "fixed"
          item.released = published_at
          item.first_released = published_at
        end

        item.state = (state == "draft") ? "closed" : "public"
        # item.category_ids = [category.id, area.id]

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        kyokagaihoiku_kigyosyudogatahoiku_row = kyokagaihoiku_kigyosyudogatahoiku_csv.find do |kyokagaihoiku_kigyosyudogatahoiku_row|
          kyokagaihoiku_kigyosyudogatahoiku_row['名称'] == title
        end
        if kyokagaihoiku_kigyosyudogatahoiku_row
          column_values[0].value = kyokagaihoiku_kigyosyudogatahoiku_row['名称']
          column_values[1].value = kyokagaihoiku_kigyosyudogatahoiku_row['カナ']
          if kyokagaihoiku_kigyosyudogatahoiku_row['画像ファイル'].present?
            path = "joruri_files/0114/embedded_files/#{::File.basename(row['image_file_upload_path'])}"
            raise "not found #{path}" if !::File.exists?(path)

            ss_file = SS::File.new
            ss_file.in_file = Fs::UploadedFile.create_from_file(path)
            ss_file.site = site
            ss_file.user = user
            ss_file.filename = ::File.basename(kyokagaihoiku_kigyosyudogatahoiku_row['画像ファイル'])
            ss_file.model = item.class.name
            ss_file.owner_item = item
            ss_file.save!
            ss_file.set(content_type: ::Fs.content_type(kyokagaihoiku_kigyosyudogatahoiku_row['画像ファイル']))
            column_values[2].file_id = ss_file.id
          end
          column_values[3].value = kyokagaihoiku_kigyosyudogatahoiku_row['郵便番号']
          column_values[4].value = kyokagaihoiku_kigyosyudogatahoiku_row['区']
          column_values[5].value = kyokagaihoiku_kigyosyudogatahoiku_row['所在地']
          column_values[6].value = kyokagaihoiku_kigyosyudogatahoiku_row['緯度']
          column_values[7].value = kyokagaihoiku_kigyosyudogatahoiku_row['経度']
          column_values[8].value = kyokagaihoiku_kigyosyudogatahoiku_row['電話番号']
          column_values[9].link_url = kyokagaihoiku_kigyosyudogatahoiku_row['URL']
          column_values[10].value = kyokagaihoiku_kigyosyudogatahoiku_row['設置主体']
          column_values[11].value = kyokagaihoiku_kigyosyudogatahoiku_row['定員']
          column_values[12].value = kyokagaihoiku_kigyosyudogatahoiku_row['対象年齢[受入]']
          column_values[13].value = kyokagaihoiku_kigyosyudogatahoiku_row['対象年齢[最終]']
          column_values[14].value = kyokagaihoiku_kigyosyudogatahoiku_row['休園日']
          column_values[15].value = kyokagaihoiku_kigyosyudogatahoiku_row['開所時間']
          column_values[16].value = kyokagaihoiku_kigyosyudogatahoiku_row['閉所時間']
          column_values[17].values = kyokagaihoiku_kigyosyudogatahoiku_row['入所に必要な認定区分'].to_s.split("\n")
          column_values[18].value = kyokagaihoiku_kigyosyudogatahoiku_row['延長保育の有無']
          column_values[19].value = kyokagaihoiku_kigyosyudogatahoiku_row['延長保育[朝の開始時間]']
          column_values[20].value = kyokagaihoiku_kigyosyudogatahoiku_row['延長保育[夕方の終了時間]']
          column_values[21].value = kyokagaihoiku_kigyosyudogatahoiku_row['延長保育[利用料]']
          column_values[22].value = kyokagaihoiku_kigyosyudogatahoiku_row['延長保育[特記事項]']
          column_values[23].value = kyokagaihoiku_kigyosyudogatahoiku_row['一時預かり保育'].present? ? 'あり' : 'なし'
          column_values[24].values = kyokagaihoiku_kigyosyudogatahoiku_row['病児・病後児保育'].to_s.split("\n")
          column_values[25].values = [kyokagaihoiku_kigyosyudogatahoiku_row['学童保育の有無'].present? ? 'あり' : 'なし']
          column_values[26].value = kyokagaihoiku_kigyosyudogatahoiku_row['備考']
          column_values[27].value = kyokagaihoiku_kigyosyudogatahoiku_row['入園料等']
          column_values[28].value = kyokagaihoiku_kigyosyudogatahoiku_row['保育料']
        end

        item.form = form
        item.column_values = column_values

        puts "#{idx}.[#{category.name}] #{item.name}"
        def item.set_updated; end
        def item.serve_static_file?; false end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_updated = updated_at
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category.name, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def destroy_facility_kyokagaihoiku_kigyosyudogatahoiku_docs
      Pippi::Joruri::Relation::Facility::KyokagaihoikuKigyosyudogatahoiku.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
