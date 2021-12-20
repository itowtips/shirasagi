module Pippi::Joruri::Importer
  class Seminar < Base
    attr_reader :user, :group, :node

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @node = Article::Node::Page.site(@site).find_by(filename: "tsunagaru/seminer/seminer", name: "子どもと大人の出張講座")
    end

    def import_seminars
      csv = CSV.open("import_seminers_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "seminer.csv")
      circle_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      circle_csv.each_with_index do |row, idx|
        no = row["管理番号"]
        image_filename = row["画像ファイル名"]
        title = row["1.講座名"]
        kana = row["2.講座名（ふりがな)"]
        genre1 = row["3.ジャンル1"]
        genre2 = row["3.ジャンル2"]
        target = row["4.対象"]
        target_remark = row["5.対象年齢"]
        number_of_people = row["6.対応可能人数"]
        date = row["7.実施日程・時間"]
        business_trip_area = row["8.出張エリア"]
        prepare = row["9.準備してほしいもの"]
        cost = row["10.費用"]
        attention = row["11.注意事項"]
        url = row["15.URL"]
        detail = row["12.講座詳細"]
        teacher = row["13.団体または講師名"]
        profile = row["14.プロフィール　講師からのメッセージなど"]
        line = row["LINE公式アカウント"]
        instagram = row["Instagram"]
        facebook = row["facebook"]
        twitter = row["Twitter"]
        manager = row["16.担当者（掲載用）"]
        tel = row["17.電話（掲載用）"]
        fax = row["18.FAX（掲載用）"]
        email = row["19.E-mail（掲載用）"]
        remark = row["備考欄（掲載用）"]
        created = row["登録日"]
        updated = row["更新日"]
        original_id = row["joruri_id"]
        original_url = row["joruri_url"]

        rel_Joruri = Pippi::Joruri::Relation::Seminar.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Seminar.new
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
        item.state = "public"

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[0].value = no
        column_values[1].value = title
        column_values[2].value = kana
        column_values[3].value = genre1
        column_values[4].value = genre2

        if target.present?
          column_values[5].values = target.split(",")
        end

        column_values[6].value = target_remark
        column_values[7].value = number_of_people
        column_values[8].value = date

        if business_trip_area.present?
          column_values[9].values = business_trip_area.split(",")
        end

        column_values[10].value = prepare
        column_values[11].value = cost
        column_values[12].value = attention

        column_values[13].link_label = url
        column_values[13].link_url = url

        column_values[14].value = detail
        column_values[15].value = teacher
        column_values[16].value = profile

        column_values[17].link_label = line
        column_values[17].link_url = line

        column_values[18].link_label = instagram
        column_values[18].link_url = instagram

        column_values[19].link_label = facebook
        column_values[19].link_url = facebook

        column_values[20].link_label = twitter
        column_values[20].link_url = twitter

        column_values[21].value = manager
        column_values[22].value = tel
        column_values[23].value = fax
        column_values[24].value = email
        column_values[25].value = remark

        #image
        if image_filename.present?
          path = "joruri_files/seminer/#{image_filename}"
          raise "not found #{path}" if !::File.exists?(path)

          ss_file = SS::File.new
          ss_file.in_file = Fs::UploadedFile.create_from_file(path)
          ss_file.site = site
          ss_file.user = user
          ss_file.filename = image_filename
          ss_file.model = item.class.name
          ss_file.owner_item = item
          ss_file.save!
          ss_file.set(content_type: ::Fs.content_type(image_filename))
          column_values[26].file_id = ss_file.id
        end

        item.column_values = column_values
        #item.created = created
        #item.updated = updated
        #item.released = updated
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

    def destroy_seminars
      Pippi::Joruri::Relation::Seminar.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
