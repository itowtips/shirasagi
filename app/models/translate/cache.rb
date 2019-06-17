class Translate::Cache
  include SS::Document

  field :api, type: String
  field :from, type: String
  field :to, type: String
  field :source_text, type: String
  field :translated_text, type: String

  field :request, type: String
  field :response, type: String
  field :errors, type: Array, default: []

  validates :api, presence: true
  validates :from, presence: true
  validates :to, presence: true
  validates :source_text, presence: true
  validates :translated_text, presence: true
end
