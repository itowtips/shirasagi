class JobDb::Incident::Base
  extend SS::Translation
  include SS::Document
  include JobDb::Referenceable
  include SS::Addon::Markdown
  include JobDb::Addon::File
  include JobDb::Addon::History

  store_in collection: "job_db_incidents"

  attr_accessor :cur_user

  class << self
    def search(params = {})
      # TODO: implementation
      all
    end
  end
end
