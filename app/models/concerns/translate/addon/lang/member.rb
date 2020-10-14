module Translate::Addon::Lang::Member
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    embeds_ids :translate_targets, class_name: "Translate::Lang"
    define_method(:translate_targets) do
      items = ::Translate::Lang.in(id: translate_target_ids).to_a
      translate_target_ids.map { |id| items.find { |item| item.id == id } }
    end

    permit_params translate_target_ids: []
  end
end
