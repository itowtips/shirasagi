class Cms::Line::EventSession
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  class ServiceExpiredError < StandardError; end

  LOCK_FOR = 5.minutes.freeze

  set_permission_name "cms_line_services", :use

  field :channel_user_id, type: String
  field :mode, type: String
  field :data, type: Hash, default: {}
  field :lock_until, type: DateTime, default: ::Time::EPOCH
  field :locked_at, type: DateTime

  validates :channel_user_id, presence: true

  def set_data(key, value)
    self.data[mode] ||= {}
    self.data[mode][key] = value
    save
  end

  def get_data(key)
    data.dig(mode, key.to_s)
  end

  class << self
    def lock(site, channel_user_id)
      base_cond = { site_id: site.id, channel_user_id: channel_user_id }
      find_or_create_by!(base_cond)

      now = Time.zone.now
      lock_timeout = now + LOCK_FOR

      criteria = self.where(base_cond)
      criteria = criteria.lt(lock_until: now)

      item = criteria.find_one_and_update({ '$set' => { lock_until: lock_timeout.utc } }, return_document: :after)
      if item
        begin
          yield(item)
          item.set(locked_at: Time.zone.now.utc)
        rescue ServiceExpiredError
          #
        ensure
          item.set(lock_until: ::Time::EPOCH)
        end
        true
      else
        Rails.logger.warn("already locked line event : #{channel_user_id}")
        false
      end
    end

    def search(params)
      criteria = all
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end
  end
end
