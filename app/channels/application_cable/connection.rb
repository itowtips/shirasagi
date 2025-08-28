module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :cur_user

    def connect
      self.cur_user = find_cur_user
    end

    private

    def session_key
      Rails.application.config.session_options[:key]
    end

    def session
      @session ||= begin
        MongoidStore::Session.find(cookies[session_key]).data rescue {}
      end
    end

    def find_cur_user
      user_id = session.dig("user", "user_id")
      user = SS::User.find(user_id) rescue nil
      return user if user

      reject_unauthorized_connection
    end
  end
end
