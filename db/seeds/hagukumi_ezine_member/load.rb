require "csv"

Dir.chdir @root = File.dirname(__FILE__)
@site = SS::Site.find_by host: ENV["site"]
@ezine_node = Ezine::Node::Page.where(site_id: @site.id, filename: "konkatsu/ezine").first

## -------------------------------------
puts "# import ezine member"

def save_ezine_member(data)
  puts data[:email]
  cond = { site_id: @site._id, email: data[:email] }

  item = Ezine::Member.find_or_create_by(cond)
  item.attributes = data
  unless item.update
    puts "#{@old_id} #{item.email} : #{item.errors.full_messages}"
    dump "#{@old_id} #{item.email} : #{item.errors.full_messages}"
  end
  item
end

filepath = "files/hagukumi_ezine_member.csv"
ezine_columns = Ezine::Column.where(site_id: @site.id, node_id: @ezine_node.id).
  map { |c| [c.name, c.id] }.to_h

table = CSV.read(filepath, headers: true, encoding: 'SJIS:UTF-8')
table.each_with_index do |row, index|
  @old_id    = row["id"].to_s.strip
  email      = row["メールアドレス"].to_s.strip
  address    = row["お住まいの市町村等"].to_s.strip
  sex        = row["性別"].to_s.strip
  age        = row["年代"].to_s.strip
  email_type = row["配信形式"].to_s.strip

  in_data = {
    ezine_columns["性別"] => sex,
    ezine_columns["年齢"] => age,
    ezine_columns["地域"] => address,
  }

  item = save_ezine_member email: email, node: @ezine_node, email_type: email_type, in_data: in_data
end
