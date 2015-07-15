module PublicBoard::Model::Post
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site

  included do
    store_in collection: "public_board_posts"

    seqid :id
    field :name, type: String
    field :text, type: String
    field :permit_comment, type: String, default: 'allow'
    field :descendants_updated, type: DateTime

    field :poster, type: String
    field :email, type: String
    field :delete_key, type: String

    permit_params :poster, :email, :delete_key
    permit_params :name, :text, :mode, :permit_comment

    validates :name, presence: true
    validates :text, presence: true
    validates :poster, presence: true
    validates :email, presence: true
    validates :delete_key, presence: true

    ## TODO fix class_name
    belongs_to :topic, foreign_key: :topic_id, class_name: "PublicBoard::Post", inverse_of: :descendants
    belongs_to :parent, foreign_key: :parent_id, class_name: "PublicBoard::Post", inverse_of: :children

    has_many :descendants, foreign_key: :topic_id, class_name: "PublicBoard::Post", dependent: :destroy, inverse_of: :topic
    has_many :children, foreign_key: :parent_id, class_name: "PublicBoard::Post", dependent: :destroy, inverse_of: :parent

    #validates :permit_comment, inclusion: {in: %w(allow deny)}, unless: :comment?

    scope :topic, ->{ exists parent_id: false }
    scope :comment, ->{ exists parent_id: true }
  end

  # Can't create a comment if its topic "permit_comment?" returns false.
  #validate -> do
  #  unless topic.permit_comment?
  #    errors.add :xxx, "Not allowed comment."
  #    # FIXME 排他制御出来ないためにこんなコード書いてる
  #    # FIXME (例:コメント本文入力中にトピックがコメント許可しないに変更)
  #    # FIXME バリデーションエラーメッセージを何処に入れれば良いのだろう？
  #  end
  #end, if: :comment?

  #before_validation :set_topic_id, if: :comment?
  #before_save :set_descendants_updated
  #after_save :update_parent_descendants_updated

  def set_descendants_updated
    self.descendants_updated = updated
  end

  # Update parent's "descendants_updated" field recursively.
  def update_parent_descendants_updated(time = nil)
    if parent.present?
      time ||= descendants_updated
      # Call low level "set" API instead of "update" to skip callbacks.
      parent.set descendants_updated: time
      parent.update_parent_descendants_updated time
    end
  end

  def root_post
    parent.nil? ? self : parent.root_post
  end

  def comment?
    parent.present?
  end

  def set_topic_id
    self.topic_id = root_post.id
  end

  def permit_comment?
    permit_comment == 'allow'
  end

  def mode_options
    [
      [I18n.t('board.topic.mode_thread'), 'thread'],
      [I18n.t('board.topic.mode_tree'), 'tree']
    ]
  end

  def permit_comment_options
    [
      [I18n.t('board.topic.permit_comment_allow'), 'allow'],
      [I18n.t('board.topic.permit_comment_deny'), 'deny']
    ]
  end
end
