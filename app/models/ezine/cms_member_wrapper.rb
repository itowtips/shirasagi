# this class provides compatible methods of Cms::Member
class Ezine::CmsMemberWrapper
  include Cms::Model::Member
  include Ezine::Addon::AdditionalAttributes
  include Ezine::Addon::Subscription
  include ::Translate::Addon::Lang::Member

  def test_member?
    false
  end
end
