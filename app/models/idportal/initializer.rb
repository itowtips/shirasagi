module Idportal
  class Initializer
    Cms::Node.plugin "idportal/page"
    Cms::Node.plugin "idportal/search"
    Cms::Part.plugin "idportal/search"
  end
end
