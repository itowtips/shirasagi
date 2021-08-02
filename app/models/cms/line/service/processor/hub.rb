class Cms::Line::Service::Processor::Hub < Cms::Line::Service::Processor::Base
  def call
    return if service.delegates.blank?

    delegated = false
    events.each do |event|
      next if delegated

      user_id = channel_user_id(event)
      next if user_id.blank?

      Cms::Line::EventSession.lock(site, user_id) do |event_session|
        begin
          self.event_session = event_session

          # default mode
          if event_session.mode.blank?
            event_session.mode = service.delegates.first.service_name
            event_session.update
          end

          # switch mode
          switched = false
          service.delegates.each do |delegate|
            if delegate.switch_mode(self, event)
              switched = true
              break
            end
          end
          next if switched

          # service expired?
          if service.expired_text.present? && service_expired?
            client.reply_message(event["replyToken"], {
              type: "text",
              text: service.expired_text
            })
            raise Cms::Line::EventSession::ServiceExpiredError
          end

          # delegate event
          service.delegates.each do |delegate|
            if delegate.delegate(self, events)
              delegated = true
              break
            end
          end
        ensure
          self.event_session = nil
        end
      end
    end
  end

  def service_expired?
    return false unless event_session
    return false unless event_session.locked_at
    Time.zone.now >= event_session.locked_at + service.expired_minutes.minutes
  end
end
