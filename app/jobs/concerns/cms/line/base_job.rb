module Cms::Line::BaseJob
  extend ActiveSupport::Concern

  MAX_MEMBERS_TO = 300.freeze

  def deliver_message(item)
    Rails.logger.info("start deliver #{item.name}")
    raise "message not published! (#{item.name})" if !item.public?

    case item.deliver_action
    when "broadcast"
      broadcast_to_members(item)
    when "multicast"
      members = item.extract_deliver_members.to_a
      Rails.logger.info("extract #{members.size} members")
      multicast_to_members(item, members)
    end
  end

  def deliver_test_message(item, test_members)
    Rails.logger.info("start test deliver #{item.name}")
    raise "message not published! (#{item.name})" if !item.public?

    Rails.logger.info("extract #{test_members.size} test members")

    multicast_to_members(item, test_members, deliver_mode: :test)
  end

  def broadcast_to_members(item, opts = {})
    deliver_mode = (opts[:deliver_mode].to_s == "test") ? "test" : "main"

    Cms::SnsPostLog::LineDeliver.create_with(item) do |log|
      begin
        log.action = item.deliver_action
        log.deliver_mode = deliver_mode

        Rails.logger.info("broadcast to members")
        res = site.line_client.broadcast(item.line_messages)

        log.messages = item.line_messages
        log.response_code = res.code
        log.response_body = res.body
        raise "#{res.code} #{res.body}" if res.code != "200"
        log.state = "success"
      rescue => e
        Rails.logger.fatal("#broadcast failed: #{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
        log.error = "broadcast failed: #{e.class} (#{e.message})"
      end
    end
  end

  def multicast_to_members(item, members, opts = {})
    deliver_mode = (opts[:deliver_mode].to_s == "test") ? "test" : "main"

    members.each_slice(MAX_MEMBERS_TO).with_index do |members_to, idx|
      names = members_to.map(&:name)
      user_ids = members_to.map(&:oauth_id)
      member_ids = members_to.map(&:id)

      require "pry"
      binding.pry

      Cms::SnsPostLog::LineDeliver.create_with(item) do |log|
        begin
          log.action = item.deliver_action
          log.multicast_user_ids = user_ids
          log.member_ids = member_ids
          log.deliver_mode = deliver_mode

          Rails.logger.info("multicast to members #{idx * user_ids.size}..#{(idx * user_ids.size) + user_ids.size}")
          names.each_with_index { |name, idx| Rails.logger.info("- #{user_ids[idx]} #{name}") }
          res = site.line_client.multicast(user_ids, item.line_messages)

          log.messages = item.line_messages
          log.response_code = res.code
          log.response_body = res.body
          raise "#{res.code} #{res.body}" if res.code != "200"
          log.state = "success"
        rescue => e
          Rails.logger.fatal("multicast failed: #{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
          log.error = "multicast failed: #{e.class} (#{e.message})"
        end
      end
    end
  end
end
