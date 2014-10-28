module Circle
  class Initializer
    Cms::Node.plugin "circle/node"
    Cms::Node.plugin "circle/page"
    Cms::Node.plugin "circle/category"
    Cms::Node.plugin "circle/location"
    Cms::Node.plugin "circle/search"
  end
end
