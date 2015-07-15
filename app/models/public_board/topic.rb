class PublicBoard::Topic
  include PublicBoard::Model::Post
  include SS::Reference::User
  include Cms::Reference::Node

  default_scope ->{ exists parent_id: false }

  public
    def allowed?(action, user, opts = {})
      return true
    end

  class << self
    public
      def allow(action, user, opts = {})
        where({})
      end

      def allowed?(action, user, opts = {})
        return true
      end
  end
end
