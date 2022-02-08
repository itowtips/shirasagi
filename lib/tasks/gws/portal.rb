module Tasks
  module Gws
    class Portal
      extend Tasks::Gws::Base

      class << self
        def sync
          each_sites do |site|
            ::Gws::Portal::SyncPresetJob.bind(site_id: site.id).perform_now
          end
        end

        def reset
          each_sites do |site|
            ::Gws::Portal::SyncPresetJob.bind(site_id: site.id).perform_now(action: :reset)
          end
        end
      end
    end
  end
end
