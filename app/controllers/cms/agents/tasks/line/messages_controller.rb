class Cms::Agents::Tasks::Line::MessagesController < ApplicationController
  include Cms::Line::TaskFilter

  def deliver
    if @message.nil?
      @task.log "message not found!"
      head :ok
      return
    end

    begin
      deliver_message(@message)
    rescue => e
      @task.log("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ensure
      @message.completed = Time.zone.now
      @message.test_completed = nil
      @message.deliver_state = "completed"
      @message.deliver_date = nil
      @message.save
    end
    head :ok
  end

  def test_deliver
    if @message.nil? || @test_members.blank?
      @task.log "message or test members not found!"
      head :ok
      return
    end

    begin
      deliver_test_message(@message, @test_members)
    rescue => e
      @task.log("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ensure
      @message.test_completed = Time.zone.now
      @message.save
    end
    head :ok
  end

  def reserve_deliver
    now = Time.zone.now
    messages = Cms::Line::Message.site(@site).where(
      :deliver_state => "ready",
      :deliver_date.ne => nil,
      :deliver_date.lte => now).to_a

    messages.each do |message|
      begin
        message.publish
        deliver_message(message)
      rescue => e
        @task.log("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
      ensure
        message.completed = now
        message.test_completed = nil
        message.deliver_state = "completed"
        message.deliver_date = nil
        message.save
      end
    end
    head :ok
  end
end
