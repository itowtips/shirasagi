module JobDb::Addon::Release
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :state, type: String
    field :released, type: DateTime
    field :release_date, type: DateTime
    field :close_date, type: DateTime
    permit_params :state, :released, :release_date, :close_date
    validates :state, presence: true
    validates :released, datetime: true
    validates :release_date, datetime: true
    validates :close_date, datetime: true
  end

  module ClassMethods
    def and_public(date = nil)
      return where(state: "public") if date.nil?

      date = date.dup
      where("$and" => [
        { "$or" => [ { state: "public", :released.lte => date }, { :release_date.lte => date } ] },
        { "$or" => [ { close_date: nil }, { :close_date.gt => date } ] },
      ])
    end
  end

  def state_options
    [
      [I18n.t('views.options.state.public'), 'public'],
      [I18n.t('views.options.state.closed'), 'closed'],
    ]
  end

  def public?
    state == 'public'
  end
end
