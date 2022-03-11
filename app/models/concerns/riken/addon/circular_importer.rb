module Riken::Addon::CircularImporter
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :riken_workflow_id, type: String
    field :riken_workflow_status, type: String
    field :riken_workflow_update_time, type: String
  end
end
