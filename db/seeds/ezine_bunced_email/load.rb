Dir.chdir @root = File.dirname(__FILE__)
@site = SS::Site.find_by host: ENV["site"]

require "csv"

CSV.foreach("bunced.csv") do |row|
  email = row[0].gsub(/\.\.\.$/, "")
  item = Ezine::Member.where(email: /^#{Regexp.escape(email)}/)
  if item.present?
    raise "duplicate! #{email}" if item.size != 1

    item = item.first
    puts item.email
    item.set(state: "disabled")
  else
    puts "??? #{email}"
  end
end

