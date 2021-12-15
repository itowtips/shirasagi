module Pippi::Joruri::Importer
  class Circle < Base
    attr_reader :site, :joruri_host, :joruri_base_url, :csv_path
    attr_reader :user, :group, :circle_node, :salon_node, :dantai_node

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")

      @circle_node = Article::Node::Page.site(@site).find_by(filename: /^tsunagaru\/group\//, name: "子育て・サークル・地域の子育て関連団体")
      @salon_node = Article::Node::Page.site(@site).find_by(filename: /^tsunagaru\/group\//, name: "子育てサークル・サロン")
      @dantai_node = Article::Node::Page.site(@site).find_by(filename: /^tsunagaru\/group\//, name: "地域の子育て関連団体")

      @circle_form = Cms::Form.site(@site).find_by(name: "子育て・サークル・地域の子育て関連団体")
      @salon_form = Cms::Form.site(@site).find_by(name: "子育てサークル・サロン")
      @dantai_form = Cms::Form.site(@site).find_by(name: "地域の子育て関連団体")
    end

    def import_circles
      csv = CSV.open("import_circle_docs_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "circle.csv")
      circle_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      circle_csv.each_with_index do |row, idx|
        no = row["管理番号"]
        image_filename = row["画像ファイル名"]
        type = row["種別"]
        title = row["名称（漢字）"]
        kana = row["名称（ふりがな）"]
        genre1 = row["ジャンル1"]
        genre2 = row["ジャンル2"]
        area1 = row["区"]
        area2 = row["地域"]
        place_name = row["活動場所名称"]
        place_address = row["活動場所住所"]
        active_date = row["活動日時"]
        cost = row["会費"]
        target = row["対象"]
        account_count = row["会員数"]
        url = row["URL"]
        line = row["LINE公式アカウント"]
        facebook = row["facebook"]
        instagram = row["Instagram"]
        summary = row["概要"]
        twitter = row["Twitter"]
        pr = row["活動内容やPR"]
        representative = row["代表者"]
        tell1 = row["電話（掲載用）"]
        tell2 = row["携帯（掲載用）"]
        email = row["E-mail（掲載用）"]
        contact_remark = row["連絡先備考"]
        created = row["登録日2"]
        updated = row["更新作業日"]
        original_id = row["joruri_id"]
        original_url = row["joruri_url"]

        rel_Joruri = Pippi::Joruri::Relation::Circle.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Circle.new
        end

        case type
        when "サークル"
          node = @circle_node
          type = "子育てサークル"
        when "サロン"
          node = @salon_node
          type = "子育てサロン"
        when "団体"
          node = @dantai_node
          type =  "子育て団体"
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
        column_values[0].value = title
        column_values[1].value = kana
        column_values[2].value = genre1
        column_values[3].value = genre2
        column_values[4].value = area1
        column_values[5].value = area2
        column_values[6].value = no
        column_values[7].value = type
        column_values[8].value = place_name
        column_values[9].value = place_address
        column_values[10].value = active_date
        column_values[11].value = cost
        column_values[12].value = target
        column_values[13].value = account_count
        column_values[14].value = summary
        column_values[15].value = pr

        column_values[16].link_label = url
        column_values[16].link_url = url

        column_values[17].link_label = line
        column_values[17].link_url = line

        column_values[18].link_label = instagram
        column_values[18].link_url = instagram

        column_values[19].link_label = facebook
        column_values[19].link_url = facebook

        column_values[20].link_label = twitter
        column_values[20].link_url = twitter

        #image
        if image_filename.present?
          path = "joruri_files/circle/#{image_filename}"
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
          column_values[21].file_id = ss_file.id
        end

        column_values[22].value = representative
        column_values[23].value = tell1
        column_values[24].value = tell2
        column_values[25].value = email
        column_values[26].value = contact_remark

        item.column_values = column_values
        item.created = created
        item.updated = updated
        item.released = updated
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

    def destroy_circles
      Pippi::Joruri::Relation::Circle.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
