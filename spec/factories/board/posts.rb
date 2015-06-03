FactoryGirl.define do
  factory :board_post, class: Board::Post do
    name 'Title'
    text 'Body'

    factory :board_topic do
      parent nil
    end

    factory :board_comment do
      association :parent, factory: :board_topic
    end

    factory :board_comment_to_comment do
      association :parent, factory: :board_comment
    end
  end
end
