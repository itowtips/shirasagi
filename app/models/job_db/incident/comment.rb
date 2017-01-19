class JobDb::Incident::Comment < JobDb::Incident::Base
  include SS::Reference::User

  attr_accessor :cur_topic, :cur_parent

  belongs_to :topic, class_name: "JobDb::Incident::Topic", inverse_of: :descendants
  # parent can be a Topic or a Comment
  belongs_to :parent, class_name: "JobDb::Incident::Base", inverse_of: :children

  before_validation :set_topic_id, if: ->{ @cur_topic }
  after_save :update_topic_descendants_updated, if: -> { topic_id.present? }

  def reference_name
    JobDb::Incident::Comment.model_name.human
  end

  private
    def set_topic_id
      self.topic_id ||= @cur_topic.id
    end

    def set_parent_id
      self.parent_id ||= (@cur_parent || @cur_topic).id
    end

    # 最新レス投稿日時、レス更新日時をトピックに設定
    # 明示的に age るケースが発生するかも
    def update_topic_descendants_updated
      return unless topic
      #return unless _id_changed?
      topic.set descendants_updated: updated
    end
end
