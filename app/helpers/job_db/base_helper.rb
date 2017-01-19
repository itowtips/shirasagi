module JobDb::BaseHelper
  extend ActiveSupport::Concern
  include JobDb::ListHelper
  include JobDb::NodeHelper
end
