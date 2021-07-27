class Cms::Line::Service::Processor::Hub < Cms::Line::Service::Processor::Base
  def call
    delegated = false
    events.each do |event|
      next if delegated

      user_id = channel_user_id(event)
      next if user_id.blank?

      Cms::Line::EventSession.lock(site, user_id) do |event_session|
        begin
          self.event_session = event_session

          # switch mode
          switched = false
          node.line_delegates.each do |delegate|
            if delegate.switch_mode(self, event)
              switched = true
              break
            end
          end
          next if switched

          # delegate event
          node.line_delegates.each do |delegate|
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
end
