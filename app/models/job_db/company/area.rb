# 地区
class JobDb::Company::Area
  extend SS::Translation
  include SS::Document
  include Sys::Permission

  set_permission_name "job_db_companies", :edit

  class << self
    def search(parasm = {})
      all
    end
  end
end
