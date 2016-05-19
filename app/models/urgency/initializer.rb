module Urgency
  class Initializer
    Cms::Node.plugin "urgency/layout"
    Cms::Node.plugin "urgency/page"

    Cms::Part.plugin "urgency/page"
  end
end
