class Recommend::CreateMatrixJob < Cms::ApplicationJob
  def perform(param = "")
    delete_matrix

    #TODO: logs term
    recommender = Recommend::History::Recommender.new
    tokens = Recommend::History::Log.pluck(:token).uniq
    tokens.each do |token|
      logs = Recommend::History::Log.where(token: token)
      items = logs.map(&:redis_key).uniq
      Rails.logger.info("#{token} [#{items.join(", ")}]")
      recommender.order_items.add_set(token, items)
    end
    recommender.process!
  end

  def delete_matrix
    Recommendify.redis.del "recommendify:order_items:ccmatrix"
    Recommendify.redis.del "recommendify:similarities"
    Recommendify.redis.del "recommendify:order_items:items"
  end
end
