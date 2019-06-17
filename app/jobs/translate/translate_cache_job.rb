class Translate::TranslateCacheJob < Cms::ApplicationJob
  def put_log(message)
    puts(message)
    Rails.logger.warn(message)
  end

  def perform
    ids = Translate::Cache.site(site).where(lang: "ja").pluck(:id)
    ids.each do |id|
      item = Translate::Cache.find(id) rescue nil
      next unless item

      put_log "\# #{item.url}"
      cache = item.create_translate("en")
      cache.save!
    end
  end
end
