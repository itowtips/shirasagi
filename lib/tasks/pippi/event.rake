namespace :pippi do
  namespace :event do
    task :create_event_pages, [:site] => :environment do |task, args|
      ::Tasks::Cms::Base.with_site(args[:site] || ENV['site']) do |site|

        @site = site
        @user = SS::User.find_by(uid: "sys")
        @layout = Cms::Layout.site(@site).find_by(name: "記事レイアウト")
        @form = Cms::Form.where(name: "イベントカレンダー").first
        @form_columns = @form.columns.order_by(order: 1).to_a

        def save_page(data)
          puts data[:name]
          cond = { site_id: @site._id, filename: data[:filename] }

          route = data[:route].presence || 'article/page'
          item = route.camelize.constantize.unscoped.find_or_initialize_by(cond)
          item.attributes = data
          item.cur_user = @user
          item.save!

          item.add_to_set group_ids: @site.group_ids

          item
        end

        def save_file(page, column_value, upload_path, filename)
          return if upload_path.blank?
          upload_path.sub!("/var/share/joruri/", "/Users/ito/pippi/joruri/")
          puts upload_path
          raise upload_path if !Fs.exists?(upload_path)

          if column_value.file
            column_value.file.destroy
          end

          item = SS::File.new
          item.in_file = Fs::UploadedFile.create_from_file(upload_path)
          item.site = @site
          item.filename = filename
          item.name = filename
          item.model = page.class.name
          item.owner_item = page
          item.save!
          item.set(content_type: ::Fs.content_type(filename))

          column_value.file = item
          column_value.save!

          item
        end

        def format_event_date(start_date, end_date)
          d1 = Date.parse(start_date) rescue nil
          d2 = Date.parse(end_date) rescue nil
          (d1 && d2) ? (d1..d2).to_a : [d1, d2].compact
        end

        path = ::File.join(Rails.root, "lib/tasks/pippi/event/event.csv")
        csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
        csv.each_with_index do |row, idx|
          name = row["name"].strip
          title = row["title"]
          facility_name = row["facility_name"]
          place_supplement = row["place_supplement"]
          category_names = row["category_names"]
          event_date1 = row["event_date1"]
          event_close_date1 = row["event_close_date1"]
          event_date2 = row["event_date2"]
          event_close_date2 = row["event_close_date2"]
          event_date3 = row["event_date3"]
          event_close_date3 = row["event_close_date3"]
          event_date4 = row["event_date4"]
          event_close_date4 = row["event_close_date4"]
          event_date5 = row["event_date5"]
          event_close_date5 = row["event_close_date5"]
          event_date_supplement = row["event_date_supplement"]
          body = row["body"]
          event_uri = row["event_uri"]
          target = row["target"]
          fee = row["fee"]
          nursery = row["nursery"]
          capacity = row["capacity"]
          advance_entry = row["advance_entry"]
          advance_supplement = row["advance_supplement"]
          circle_name = row["circle_name"]
          sponsor_supplement = row["sponsor_supplement"]
          inquiry_email = row["inquiry_email"]
          inquiry_tel = row["inquiry_tel"]
          inquiry_uri = row["inquiry_uri"]
          memo = row["memo"]
          image_file_name = row["image_file_name"]
          image_file_upload_path = row["image_file_upload_path"]
          image2_file_name = row["image2_file_name"]
          image2_file_upload_path = row["image2_file_upload_path"]
          image3_file_name = row["image3_file_name"]
          image3_file_upload_path = row["image3_file_upload_path"]
          append_file_name = row["append_file_name"]
          append_file_upload_path = row["append_file_upload_path"]
          append2_file_name = row["append2_file_name"]
          append2_file_upload_path = row["append2_file_upload_path"]
          append3_file_name = row["append3_file_name"]
          append3_file_upload_path = row["append3_file_upload_path"]
          state = row["state"]

          inquiry = [inquiry_email, inquiry_tel, inquiry_uri].select(&:present?).join("\n")

          event_dates = []
          event_dates += format_event_date(event_date1, event_close_date1)
          event_dates += format_event_date(event_date2, event_close_date2)
          event_dates += format_event_date(event_date3, event_close_date3)
          event_dates += format_event_date(event_date4, event_close_date4)
          event_dates += format_event_date(event_date5, event_close_date5)
          event_dates.uniq!
          event_dates = event_dates.map { |d| d.strftime("%Y/%m/%d") }.join("\r\n")

          page = save_page filename: "calendar/docs/page#{idx + 1}-n#{name}.html", name: title,
            layout_id: @layout.id, form_id: @form.id,
            event_dates: event_dates,
            column_values: [
              @form_columns[0].value_type.new(column: @form_columns[0], value: facility_name),
              @form_columns[1].value_type.new(column: @form_columns[1], value: place_supplement),
              @form_columns[2].value_type.new(column: @form_columns[2], value: category_names),
              @form_columns[3].value_type.new(column: @form_columns[3], value: event_date_supplement),
              @form_columns[4].value_type.new(column: @form_columns[4], value: body),
              @form_columns[5].value_type.new(column: @form_columns[5], link_url: event_uri),
              @form_columns[6].value_type.new(column: @form_columns[6], value: target),
              @form_columns[7].value_type.new(column: @form_columns[7], value: fee),
              @form_columns[8].value_type.new(column: @form_columns[8], value: nursery),
              @form_columns[9].value_type.new(column: @form_columns[9], value: capacity),
              @form_columns[10].value_type.new(column: @form_columns[10], value: advance_entry),
              @form_columns[11].value_type.new(column: @form_columns[11], value: advance_supplement),
              @form_columns[12].value_type.new(column: @form_columns[12], value: circle_name),
              @form_columns[13].value_type.new(column: @form_columns[13], value: sponsor_supplement),
              @form_columns[14].value_type.new(column: @form_columns[14], value: inquiry),
              @form_columns[15].value_type.new(column: @form_columns[15], value: memo),
              @form_columns[16].value_type.new(column: @form_columns[16], file_id: nil),
              @form_columns[17].value_type.new(column: @form_columns[17], file_id: nil),
              @form_columns[18].value_type.new(column: @form_columns[18], file_id: nil),
              @form_columns[19].value_type.new(column: @form_columns[19], file_id: nil),
              @form_columns[20].value_type.new(column: @form_columns[20], file_id: nil),
              @form_columns[21].value_type.new(column: @form_columns[21], file_id: nil),
            ],
            state: (state == "draft") ? "closed" : "public"

          save_file(page, page.column_values[16], image_file_upload_path, image_file_name)
          save_file(page, page.column_values[17], image2_file_upload_path, image2_file_name)
          save_file(page, page.column_values[18], image3_file_upload_path, image3_file_name)
          save_file(page, page.column_values[19], append_file_upload_path, append_file_name)
          save_file(page, page.column_values[20], append2_file_upload_path, append2_file_name)
          save_file(page, page.column_values[21], append3_file_upload_path, append3_file_name)
        end
      end
    end
  end
end
