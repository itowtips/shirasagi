Dir.chdir @root = File.dirname(__FILE__)
@site = SS::Site.find_by host: ENV["site"]

## -------------------------------------

Cms::Page.all.each do |item|
  item.files.each do |f|
    if item.state == "closed" && f.state == "public"
      puts "#{item.name} #{f.name}"
      f.update_attributes(state: item.state)
    end
  end
end

