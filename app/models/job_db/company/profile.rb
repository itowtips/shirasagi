# 企業情報
class JobDb::Company::Profile
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
