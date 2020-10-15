class Facility::Node::Importer
  include Cms::CsvImportBase

  self.required_headers = [ ::Facility::Node::Page.t(:filename) ]

  attr_reader :site, :node, :user

  def initialize(site, node, user)
    @site = site
    @node = node
    @user = user
  end

  def import(file, opts = {})
    @task = opts[:task]

    put_log("import start #{file.filename}")
    import_csv(file)
  end

  private

  def model
    ::Facility::Node::Page
  end

  def put_log(message)
    if @task
      @task.log(message)
    else
      Rails.logger.info(message)
    end
  end

  def import_csv(file)
    table = CSV.read(file.path, headers: true, encoding: 'SJIS:UTF-8')
    table.each_with_index do |row, i|
      begin
        name = update_row(row)
        put_log("update #{i + 1}: #{name}")
      rescue => e
        put_log("error  #{i + 1}: #{e}")
      end
    end
  end

  def update_row(row)
    filename = "#{node.filename}/#{row[model.t(:filename)]}"
    item = model.find_or_initialize_by filename: filename, site_id: site.id
    item.cur_site = site
    set_page_attributes(row, item)

    if item.save
      name = item.name
    else
      raise item.errors.full_messages.join(", ")
    end

    if row[model.t(:map_points)].present?
      filename = "#{filename}/map.html"
      map = ::Facility::Map.find_or_create_by filename: filename
      set_map_attributes(row, map)
      map.site = site
      map.save
      name += " #{map.map_points.first.try(:[], "loc")}"
    end

    return name
  end

  def set_page_attributes(row, item)
    item.name            = row[model.t(:name)].try(:squish)
    item.layout          = Cms::Layout.site(site).where(name: row[model.t(:layout)].try(:squish)).first
    item.page_link       = row[model.t(:page_link)].try(:squish)
    item.kana            = row[model.t(:kana)].try(:squish)
    item.address         = row[model.t(:address)].try(:squish)
    item.postcode        = row[model.t(:postcode)].try(:squish)
    item.tel             = row[model.t(:tel)].try(:squish)
    item.fax             = row[model.t(:fax)].try(:squish)
    item.related_url     = row[model.t(:related_url)].try(:gsub, /[\r\n]/, " ")
    item.additional_info = row.to_h.select { |k, v| k =~ /^#{model.t(:additional_info)}[:：]/ && v.present? }.
        map { |k, v| {:field => k.sub(/^#{model.t(:additional_info)}[:：]/, ""), :value => v} }

    set_page_categories(row, item)
    ids = SS::Group.in(name: row[model.t(:groups)].to_s.split(/\n/)).map(&:id)
    item.group_ids = SS::Extensions::ObjectIds.new(ids)
  end

  def set_page_categories(row, item)
    names = row[model.t(:categories)].to_s.split(/\n/).map(&:strip)
    ids = node.st_categories.in(name: names).map(&:id)
    item.category_ids = SS::Extensions::ObjectIds.new(ids)

    names = row[model.t(:locations)].to_s.split(/\n/).map(&:strip)
    ids = node.st_locations.in(name: names).map(&:id)
    item.location_ids = SS::Extensions::ObjectIds.new(ids)

    names = row[model.t(:services)].to_s.split(/\n/).map(&:strip)
    ids = node.st_services.in(name: names).map(&:id)
    item.service_ids = SS::Extensions::ObjectIds.new(ids)
  end

  def set_map_attributes(row, item)
    points = row[model.t(:map_points)].split(/\n/).map do |loc|
      { loc: Map::Extensions::Loc.mongoize(loc) }
    end

    item.name = "map"
    item.map_points = Map::Extensions::Points.new(points)
  end
end
