module Schedule::Planable
  extend ActiveSupport::Concern

  included do
    include SS::Document

    field :name, type: String
    field :text, type: String
    field :start_at, type: DateTime
    field :end_at, type: DateTime
    field :allday, type: Boolean

    validates :text, presence: true
    validates :start_at, presence: true
    validates :end_at, presence: true

    validate do
      errors.add(:start_at, "can't create an event that ends before it starts.") if start_at >= end_at
    end

    validates :allday, inclusion: {in: [true, false]}

    permit_params :name, :text, :start_at, :end_at, :allday
  end
end
