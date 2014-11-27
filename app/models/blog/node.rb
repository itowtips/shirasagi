module Blog::Node
  class Base
    include Cms::Node::Model

    default_scope ->{ where(route: /^blog\//) }
  end

  class Page
    include Cms::Node::Model
    include Cms::Addon::PageList

    default_scope ->{ where(route: "blog/page") }
  end
end
