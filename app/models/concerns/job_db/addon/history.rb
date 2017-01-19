module JobDb::Addon::History
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    after_save :save_history_for_save
    after_destroy :save_history_for_destroy
  end

  def histories
    @histroies ||= JobDb::History.where(model: reference_model, item_id: id)
  end

  def skip_job_db_history
    @skip_job_db_history = true
  end

  private
    def save_history_for_save
      return if @db_changes.blank?

      if @db_changes.key?('_id')
        save_history mode: 'create'
      else
        save_history mode: 'update', updated_fields: @db_changes.keys.reject { |s| s =~ /_hash$/ }
      end
    end

    def save_history_for_destroy
      save_history mode: 'delete' # @flagged_for_destroy
    end

    def save_history(overwrite_params = {})
      return if @skip_job_db_history

      item = ::JobDb::History.new(
        cur_user: @cur_user,
        name: reference_name,
        model: reference_model,
        item_id: id
      )
      item.attributes = overwrite_params
      item.save
    end
end
