Dir.chdir @root = File.dirname(__FILE__)
@site = SS::Site.find_by host: ENV["site"]

## -------------------------------------

require "csv"

CSV.open("./dropped_files.csv", "wb") do |csv|

csv << ["添付ファイル作成日", "添付ファイル名", "添付ファイルURL", "添付されているページ", "HTMLにURL記述があるページ"]

selector = SS::File.in(model: [ "article/page", "faq/page", "cms/page",  "event/page"])
size = selector.size
selector.each_with_index do |f, idx|

  puts "[#{idx}/#{size}]"

  row = []
  row << f.created.strftime("%Y/%m/%d %H:%M")
  row << f.name
  row << ::File.join(@site.full_url, f.old_url)

  page =  Cms::Page.in(file_ids: f.id).first

  unless page
    row << "none"

    in_pages = Cms::Page.where(html: /=\"(#{Regexp.escape(f.old_url)}|#{Regexp.escape(f.url)})/)
    if in_pages.present?
      #in_pages.each do |in_page|
      #  row << ::File.join(@site.full_url, in_page.url)
      #end
      row << in_pages.map { |in_page| ::File.join(@site.full_url, in_page.url) }.join("\n")

      #add to set dropped file id
      in_page = in_pages.first
      in_page.add_to_set(file_ids: f.id)
      row << "set id"
    else
      row << "none"

      #close file
      f.update_attributes(state: "closed")
      row << "chage state to closed"
    end
  else
    row << page.full_url
  end

  csv << row
end

end

