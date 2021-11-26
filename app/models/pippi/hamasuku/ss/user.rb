module Pippi::Hamasuku
  module SS
    class User
      include ::SS::Document
      store_in client: :hamasuku, collection: :ss_users
    end
  end
end
