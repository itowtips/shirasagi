module Facility::Addon
  module GeolocationList
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    def condition_hash
      cond = []

      cond << { filename: /^#{filename}\// } if conditions.blank?
      conditions.each do |url|
        node = Cms::Node.filename(url).first
        next unless node
        cond << { filename: /^#{node.filename}\// }
      end

      { '$or' => cond }
    end
  end
end
