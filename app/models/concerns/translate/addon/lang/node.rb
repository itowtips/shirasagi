module Translate::Addon::Lang::Node
  extend SS::Addon
  extend ActiveSupport::Concern

  def translate_targets
    ids = Ezine::Page.site(site).node(self).and_public.pluck(:translate_target_ids).flatten.uniq.compact
    [site.translate_source, site.translate_targets].flatten.uniq.compact.select do |lang|
      ids.include?(lang.id)
    end
  end
end
