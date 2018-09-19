# ref
# https://github.com/ckan/ckan/blob/master/doc/api/index.rst
# https://github.com/ckan/ckan/blob/master/ckan/logic/action/get.py
# https://github.com/ckan/ckan/blob/master/ckan/logic/action/create.py
# https://github.com/ckan/ckan/blob/master/ckan/logic/action/update.py
# https://github.com/ckan/ckan/blob/master/ckan/logic/action/delete.py

class Opendata::Harvest::CkanPackage
  attr_accessor :url

  private

  def validate_result(api, result)
    raise "#{api} failed #{result}" if result["success"] != true
  end

  public

  def initialize(url)
    @url = url
  end

  ## urls

  def dataset_url(name)
    ::File.join(url, "dataset", name)
  end

  def resource_url(dataset_name, id)
    ::File.join(url, "dataset", dataset_name, "resource",id)
  end

  def package_list_url
    ::File.join(url, "api/action/package_list")
  end

  def package_show_url(id = nil)
    if id
      ::File.join(url, "api/action/package_show") + "?id=#{id}"
    else
      ::File.join(url, "api/action/package_show")
    end
  end

  def package_create_url
    ::File.join(url, "api/action/package_create")
  end

  def package_update_url
    ::File.join(url, "api/action/package_update")
  end

  def package_patch_url
    ::File.join(url, "api/action/package_patch")
  end

  def package_delete_url
    ::File.join(url, "api/action/package_delete")
  end

  def dataset_purge_url
    ::File.join(url, "api/action/dataset_purge")
  end

  def resource_create_url
    ::File.join(url, "api/action/resource_create")
  end

  def resource_update_url
    ::File.join(url, "api/action/resource_update")
  end

  def resource_patch_url
    ::File.join(url, "api/action/resource_patch")
  end

  def resource_delete_url
    ::File.join(url, "api/action/resource_delete")
  end

  ## package(dataset) apis

  def package_list
    result = open(package_list_url, read_timeout: 20).read
    result = ::JSON.parse(result)
    validate_result("package_list", result)
    result["result"]
  end

  def package_show(id)
    result = open(package_show_url(id), read_timeout: 20).read
    result = ::JSON.parse(result)
    validate_result("package_show", result)
    result["result"]
  end

  def package_create(params, api_key)
    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post package_create_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("package_create", result)
    result["result"]
  end

  def package_update(id, params, api_key)
    params[:id] = id

    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post package_update_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("package_update", result)
    result["result"]
  end

  def package_patch(id, params, api_key)
    params[:id] = id

    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post package_patch_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("package_patch", result)
    result["result"]
  end


  # soft delete
  def package_delete(id, api_key)
    params = { id: id }

    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post package_delete_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("package_delete", result)
    result["result"]
  end

  def dataset_purge(id, api_key)
    params = { id: id }

    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post dataset_purge_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("dataset_purge", result)
    result["result"]
  end

  ## resource apis

  def resource_create(package_id, params, api_key, file = nil)
    params[:package_id] = package_id
    params[:upload] = ::Faraday::UploadIO.new(file.path, file.content_type, file.filename) if file

    if params[:upload]
      request = :multipart
    else
      request = :url_encoded
      params = params.to_json
    end

    conn = ::Faraday.new do |f|
      f.request request
      f.adapter :net_http
    end

    res = conn.post resource_create_url do |req|
     req.options.timeout = 10
     req.headers['Authorization'] = api_key
     req.body = params
    end

    result = ::JSON.parse(res.body)
    validate_result("resource_create", result)
    result["result"]
  end

  def resource_update(id, params, api_key, file = nil)
    params[:id] = id
    params[:upload] = ::Faraday::UploadIO.new(file.path, file.content_type, file.filename) if file

    if params[:upload]
      request = :multipart
    else
      request = :url_encoded
      params = params.to_json
    end

    conn = ::Faraday.new do |f|
      f.request request
      f.adapter :net_http
    end

    res = conn.post resource_update_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params
    end

    result = ::JSON.parse(res.body)
    validate_result("resource_update", result)
    result["result"]
  end

  def resource_patch(id, params, api_key, file = nil)
    params[:id] = id
    params[:upload] = ::Faraday::UploadIO.new(file.path, file.content_type, file.filename) if file

    if params[:upload]
      request = :multipart
    else
      request = :url_encoded
      params = params.to_json
    end

    conn = ::Faraday.new do |f|
      f.request request
      f.adapter :net_http
    end

    res = conn.post resource_patch_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params
    end

    result = ::JSON.parse(res.body)
    validate_result("resource_patch", result)
    result["result"]
  end

  def resource_delete(id, api_key)
    params = { id: id }

    conn = ::Faraday.new do |f|
      f.request :url_encoded
      f.adapter :net_http
    end

    res = conn.post resource_delete_url do |req|
      req.options.timeout = 10
      req.headers['Authorization'] = api_key
      req.body = params.to_json
    end

    result = ::JSON.parse(res.body)
    validate_result("resource_delete", result)
    result["result"]
  end

=begin
  def package_list_to_csv
    list = package_list
    CSV.generate do |data|
      data << %w(title notes license_title resources groups organization url)

      list.each do |id|
        puts id
        package = package_show(id)
        line = []
        line << package["title"]
        line << package["notes"]
        line << package["license_title"]
        line << package["resources"].map { |resources| resources["name"] }.join("\n")
        line << package["groups"].map { |resources| resources["title"] }.join("\n")
        line << package.dig("organization", "title")
        line << ::File.join(url, "/dataset/#{id}")
        data << line
      end
    end
  end
=end
end
