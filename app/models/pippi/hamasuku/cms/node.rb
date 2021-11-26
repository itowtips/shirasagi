module Pippi::Hamasuku
  module Cms
    class Node
      include ::SS::Document
      store_in client: :hamasuku, collection: :cms_nodes
    end
  end
end
