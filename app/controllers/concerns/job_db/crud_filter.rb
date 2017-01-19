module JobDb::CrudFilter
  extend ActiveSupport::Concern
  include Sys::CrudFilter

  def index
    raise "403" unless @model.allowed?(:read, @cur_user)
    @items = @model.allow(:read, @cur_user).
      search(params[:s]).
      order_by(_id: -1).
      page(params[:page]).per(50)
  end
end
