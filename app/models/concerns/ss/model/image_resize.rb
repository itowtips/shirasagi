module SS::Model::ImageResize
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document

  included do
    seqid :id
    field :name, type: String
    field :max_width, type: Integer
    field :max_height, type: Integer
    field :order, type: Integer
    field :default_selected, type: String, default: "disabled"

    permit_params :name, :max_width, :max_height, :order, :default_selected

    validates :name, presence: true, length: { maximum: 40 }
    validates :max_width, numericality: { only_integer: true, greater_than_or_equal_to: 200 }
    validates :max_height, numericality: { only_integer: true, greater_than_or_equal_to: 200 }
    validates :order, presence: true

    default_scope ->{ order_by(default_selected: -1, order: 1) }

    after_save :uniquelize_default_selected, if: ->{ default_selected? }
  end

  def order
    value = self[:order].to_i
    value < 0 ? 0 : value
  end

  def default_selected_options
    %w(enabled disabled).map { |m| [I18n.t("ss.options.state.#{m}"), m] }
  end

  def default_selected?
    default_selected == "enabled"
  end

  private

  def uniquelize_default_selected
    items = self.class.site(site).where(default_selected: "enabled")
    items.each do |item|
      next if id == item.id
      item.default_selected = "disabled"
      item.update
    end
  end

  module ClassMethods
    def search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end

    def to_options
      self.all.to_a.map { |item| [item.name, "#{item.max_width},#{item.max_height}"] }
    end

    def default_option
      item = self.where(default_selected: "enabled").first
      return unless item
      "#{item.max_width},#{item.max_height}"
    end
  end
end
