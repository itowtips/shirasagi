module Cms::Addon
  module Menu
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :links, type: Array, default: []
      permit_params links: [ :name, :content, :url, :id, :state ]

      validate :validate_links
    end

    def validate_links
      self.links = links.select { |link| link[:content].present? && link[:id].present? }
    end

    def content_options
      [
        [I18n.t('cms.options.content.node'), 'node'],
        [I18n.t('cms.options.content.page'), 'page'],
      ]
    end

    def menu_links
      return [] unless links.present?

      links.map do |link|
        item = nil

        if link[:content] == "page"
          item = Cms::Page.site(site).where(id: link[:id]).first
        elsif link[:content] == "node"
          item = Cms::Node.site(site).where(id: link[:id]).first
        end

        if item
          { item: item, content: link[:content] }
        else
          nil
        end
      end.compact
    end
  end
end
