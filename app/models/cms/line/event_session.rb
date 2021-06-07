class Cms::Line::EventSession
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_line_event_sessions", :use

  field :channel_user_id, type: String
  field :mode, type: String, default: "ai-agent"
  field :lock_until, type: DateTime, default: ::Time::EPOCH

  validates :channel_user_id, presence: true

  LOCK_FOR = 5.minutes.freeze

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
