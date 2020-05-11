namespace :idportal do
  task res_urls: :environment do
    conf = SS.config.idportal[:mysql]
    @client = Mysql2::Client.new(host: conf["host"], username: conf["username"], password: conf["password"])
    @client.select_db(conf["database"])

    domains = []
    csv = CSV.generate do |data|
      data << %w(RID title URL rURL c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 disp リンク ドメイン IDポータル上にファイルがある)

      query = "SELECT * FROM resource00 "
      query += "WHERE "
      query += "FIND_IN_SET('idp', disp) "
      query += "AND "
      query += "NOT FIND_IN_SET('disable', disp) "

      res = @client.query(query)
      res.each do |row|
        line = []
        line << row["RID"]
        line << row["title"]
        line << row["URL"]
        line << row["rURL"]
        line << row["c1"]
        line << row["c2"]
        line << row["c3"]
        line << row["c4"]
        line << row["c5"]
        line << row["c6"]
        line << row["c7"]
        line << row["c8"]
        line << row["c9"]
        line << row["c10"]
        line << row["c11"]
        line << row["c12"]
        line << row["c13"]
        line << row["c14"]
        line << row["c15"]
        line << row["disp"]

        link = []
        if row["URL"].present? && ::File.extname(row["URL"]) =~ /^\.(pdf|doc|docx|xls|xlsx|ppt|pptx|gif|png)$/i
          link << row["URL"]
        end
        1.upto(15) do |n|
          break if row["c#{n}"].blank?
          _, l = row["c#{n}"].split(",")
          link << l
        end
        line << link.join("\n")

        domains = link.map { |link| Addressable::URI.parse(link).host.to_s }
        line << domains.join("\n")

        if domains.select { |domain| domain == "www2.gsis.kumamoto-u.ac.jp" || domain == "idportal.gsis.kumamoto-u.ac.jp" }.first
          line << "○"
        end

        data << line
      end
    end
    print csv
  end
end
