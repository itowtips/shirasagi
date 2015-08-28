require "csv"

class Faq::Page::ImportJob
  include Job::Worker

  public
    def call(csv_path, node_path, host)
      # put your business logic here

      @count = 0
      @cur_site = SS::Site.where(host: host).first
      @cur_node = Cms::Node.where(filename: node_path, site_id: @cur_site.id).first

      import_csv(csv_path)

      puts "#{csv_path}"
    end

    def update_row(row)
      # extract attribute
      filename     = (row["FAQコード"] || row["FAQコード（ファイル名）"]).to_s.gsub(/\s/, "")
      name         = (row["タイトル"] || row["質問"]).to_s.gsub(/\s/, "").sub(/^【公開】/, "").truncate(80)
      html         = row["回答"].to_s.gsub(/\s/, "")
      question     = (row["タイトル"] || row["質問"]).to_s.gsub(/\s/, "").sub(/^【公開】/, "")

      raise "FAQコード（ファイル名）を入力してください。" if filename.blank?

      group_name   = [row["担当部局"].to_s.sub(/^\d+?__/, ""), row["担当課"].to_s.sub(/^\d+?__/, "")].join("/")
      group        = Cms::Group.where(name: /#{group_name}/).first

      small_category = row["小カテゴリ"].to_s.sub(/^\d+?__/, "")
      large_category = row["大カテゴリ"].to_s.sub(/^\d+?__/, "")

      layout = Cms::Layout.where(name: row["layout"]).first || Cms::Layout.where(name: "記事（よくあるご質問）").first

      release_date = Date.parse(row["公開日"].to_s.sub("None", "")) rescue nil
      close_date   = Date.parse(row["公開期限"].to_s.sub("None", "")) rescue nil

      # item find or create
      filename     = ::File.join(@cur_node.filename, filename)
      filename     = filename + ".html" unless filename =~ /\.html$/
      cond = { site_id: @cur_site.id, filename: filename }
      item = Faq::Page.find_or_create_by(cond)

      # set attribute and save
      item.name = name
      item.html = html
      item.question = question
      item.layout = layout
      item.category_ids = [@faq_categories[small_category], @faq_categories[large_category]].compact

      if group
        item.contact_group_id = group.id
        item.contact_email = group.contact_email
        item.contact_tel = group.contact_tel
        item.contact_fax = group.contact_fax
      end

      if release_date && close_date
        if release_date >= close_date
          release_date = nil
          close_date   = nil
          item.state = "public"
        end
      elsif release_date == nil && close_date == nil
        item.state = "closed"
      elsif release_date
        #
      elsif close_date
        #
      end

      item.release_date = release_date
      item.close_date   = close_date

      if item.save
        @count += 1
        item
      else
        raise item.errors.full_messages.join(", ")
      end
    end

    def import_csv(csv_path)
      st_categories = @cur_node.becomes_with_route.st_categories
      if st_categories.present?
        @faq_categories = Category::Node::Base.any_of(st_categories.map{|c| {filename: /^#{c.filename}\//} }).
          map{|c| [c.name, c.id] }.to_h
      else
        @faq_categories = {}
      end

      table = CSV.read(csv_path, headers: true, encoding: 'SJIS:UTF-8')
      table.each_with_index do |row, idx|
        begin
          item = update_row(row)
          Rails.logger.info("update #{idx + 1}: #{item.name}")
        rescue => e
          Rails.logger.info("error  #{idx + 1}: #{e.to_s}")
        end
      end
    end

end
