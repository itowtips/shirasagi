module Board::Addon
  module AnpiPostSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :text_size_limit, type: Integer, default: 100
      # field :deletable_post, type: String, default: "enabled"
      # field :deny_url, type: String, default: "deny"
      # field :banned_words, type: SS::Extensions::Words, default: ""
      field :deny_ips, type: SS::Extensions::Words, default: ""

      validates :text_size_limit, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 400 }
      # validates :deletable_post, inclusion: { in: %w(enabled disabled) }, if: ->{ deletable_post.present? }
      # validates :deny_url, inclusion: { in: %w(deny allow) }, if: ->{ deny_url.present? }

      # permit_params :text_size_limit, :deletable_post, :deny_url, :banned_words, :deny_ips
      permit_params :text_size_limit, :deny_ips
    end

    public
      # def deletable_post?
      #   deletable_post == "enabled"
      # end

      # def deny_url?
      #   deny_url == "deny"
      # end

      # def deletable_post_options
      #   %w(disabled enabled).map { |m| [ I18n.t("board.options.deletable_post.#{m}"), m ] }.to_a
      # end

      # def deny_url_options
      #   %w(deny allow).map { |m| [ I18n.t("board.options.deny_url.#{m}"), m ] }.to_a
      # end

      def text_size_limit_options
        [400, 200, 100, 0].map { |m| [ I18n.t("board.options.text_size_limit.l#{m}"), m ] }.to_a
      end
  end
end
