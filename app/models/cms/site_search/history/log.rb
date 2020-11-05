class Cms::SiteSearch::History::Log
  include SS::Document
  include SS::Reference::Site

  store_in_repl_master
  index({ created: -1 })

  field :token, type: String
  field :query, type: Hash
  field :remote_addr, type: String
  field :user_agent, type: String

  validates :token, presence: true
  validates :query, presence: true
  before_validation :set_token

  default_scope -> { order_by(created: -1) }

  def set_token
    return if token
    self.token = SecureRandom.hex(16)
  end
end
