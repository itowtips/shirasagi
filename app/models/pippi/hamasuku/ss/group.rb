module Pippi::Hamasuku
  module SS
    class Group
      include ::SS::Document
      store_in client: :hamasuku, collection: :ss_groups
    end
  end
end
