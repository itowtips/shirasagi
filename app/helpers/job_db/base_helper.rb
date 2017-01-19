module JobDb::BaseHelper
  extend ActiveSupport::Concern
  include JobDb::ListHelper
  include JobDb::NodeHelper
  include JobDb::LayoutHelper
end
