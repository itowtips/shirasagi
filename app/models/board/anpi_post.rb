class Board::AnpiPost
  include Board::Model::AnpiPost
  include Board::Addon::MapPoint
  include Board::Addon::GooglePersonFinder
  include SS::Reference::Site
  include SS::Reference::User
  include Cms::Reference::Member
  include Board::Addon::AnpiPostPermission
  include SimpleCaptcha::ModelHelpers

  attr_accessor :cur_node

  field :delete_key, type: String
  permit_params :delete_key

  apply_simple_captcha
  permit_params :captcha, :captcha_key

  before_validation :copy_basic_attributes
  validate :validate_text, if: -> { @cur_node && @cur_node.text_size_limit != 0 }
  validate :validate_delete_key, if: ->{ user.nil? && @cur_node && @cur_node.deletable_post? }
  validate :validate_banned_words, if: -> { @cur_node && @cur_node.banned_words.present? }
  validate :validate_deny_url, if: -> { @cur_node && @cur_node.deny_url? }

  class << self
    public
      def to_csv
        CSV.generate do |data|
          data << %w(name poster text email poster_url delete_key)
          criteria.each do |item|
            line = []
            line << item.name
            line << item.poster
            line << item.text
            line << item.email
            line << item.poster_url
            line << item.delete_key
            data << line
          end
        end
      end

      def search(params = {})
        criteria = self.where({})
        return criteria if params.blank?

        if params[:name].present?
          criteria = criteria.search_text params[:name]
        end
        if params[:keyword].present?
          criteria = criteria.keyword_in params[:keyword], :name, :kana, :tel, :addr, :age, :email
        end
        criteria
      end

      def and_member_group(group)
        self.in(member_id: group.enabled_members.map(&:id))
      end
  end

  private
    def copy_basic_attributes
      return if @cur_member.blank?

      self.name ||= @cur_member.name
      self.email ||= @cur_member.email
      self.kana ||= @cur_member.kana if @cur_member.respond_to?(:kana) && @cur_member.kana.present?
      self.tel ||= @cur_member.tel if @cur_member.respond_to?(:tel) && @cur_member.tel.present?
      self.addr ||= @cur_member.addr if @cur_member.respond_to?(:addr) && @cur_member.addr.present?
      self.sex ||= @cur_member.sex if @cur_member.respond_to?(:sex) && @cur_member.sex.present?
      self.age ||= @cur_member.addr if @cur_member.respond_to?(:age) && @cur_member.age.present?
    end

  public
    def valid_with_captcha?(node)
      node.captcha_enabled? ? super() : true
    end

    def validate_text
      return if text.blank? || @cur_node.blank?
      errors.add :text, :too_long, count: @cur_node.text_size_limit if text.size > @cur_node.text_size_limit
    end

    def validate_delete_key
      errors.add :delete_key, I18n.t('board.errors.invalid_delete_key') if delete_key !~ /^[a-zA-Z0-9]{4}$/
    end

    def validate_banned_words
      cur_node.banned_words.each do |word|
        errors.add :name, :invalid_word, word: word if name =~ /#{word}/
        errors.add :text, :invalid_word, word: word if text =~ /#{word}/
        errors.add :poster, :invalid_word, word: word if poster =~ /#{word}/
      end
    end

    def validate_deny_url
      if text =~ %r{https?://[\w/:%#\$&\?\(\)~\.=\+\-]+}
        errors.add :text, I18n.t('board.errors.not_allow_urls')
      end
    end

    def modified_text
      text = self.text
      text.gsub!(%r{https?://[\w/:%#\$&\?\(\)~\.=\+\-]+}) do |href|
        "<a href=\"#{href}\">#{href}</a>"
      end
      text.gsub(/(\r\n?)|(\n)/, "<br />").html_safe
    end
end
