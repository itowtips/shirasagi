namespace :translate do
  task create_cache: :environment do
    puts "# pages"
    @site = SS::Site.first

    pages = Cms::Page.site(@site).and_public
    ids   = pages.pluck(:id)

    ids.each do |id|
      page = Cms::Page.site(@site).and_public.where(id: id).first
      next unless page

      page = page.becomes_with_route
      next unless page.translatable?

      # generate_file
      page.serve_static_relation_files = @attachments
      page.generate_file

      if !::File.exists?(page.path)
        puts "not exist : #{page.path}"
        next
      end

      # create cache
      html = ::Fs.binread(page.path)

      cache = Translate::HtmlCache.where(url: page.url, lang: "ja").first
      cache ||= Translate::HtmlCache.new
      cache.site = @site
      cache.name = page.name
      cache.url = page.url
      cache.target_id = page.id
      cache.target_class = page.class.to_s
      cache.html = html
      cache.lang = "ja"
      cache.save!
    end
  end

  task translate_cache: :environment do
    puts "Please input site_name: site=[site_host]" or exit if ENV['site'].blank?
    site = SS::Site.find_by(host: ENV['site'])
    Translate::TranslateCacheJob.bind(site_id: site.id).perform_later
  end
end
