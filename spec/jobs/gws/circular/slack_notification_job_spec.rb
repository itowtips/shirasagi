require 'spec_helper'

describe Gws::Circular::SlackNotificationJob, dbscope: :example do
  let(:requests) { [] }
  let!(:site) { Gws::Group.create(name: "シラサギ市") }
  let(:group1) { create :cms_group, name: "#{site.name}/#{unique_id}" }
  let(:group2) { create :cms_group, name: "#{site.name}/#{unique_id}" }

  let!(:notify_user1) do
    create(:gws_user, group_ids: [ group1.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U01NOTIFY01')
  end
  let!(:notify_user2) do
    create(:gws_user, group_ids: [ group2.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U02NOTIFY01')
  end
  let!(:notify_user3) do
    create(:gws_user, group_ids: [ group2.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U03NOTIFY01')
  end
  let!(:silence_user) do
    create(:gws_user, group_ids: [ group1.id ], notice_circular_slack_user_setting: 'silence',
      send_notice_slack_id: 'U03SILENCE')
  end

  let(:post_group) do
    create(:gws_circular_post, :due_date, site: site, user: notify_user1,
      member_group_ids: [group1.id, group2.id])
  end
  let(:post_member) do
    create(:gws_circular_post, :due_date, site: site, user: notify_user1,
      member_ids: [notify_user1.id, notify_user2.id, silence_user.id])
  end
  let(:post_custom_group) do
    create(:gws_circular_post, :due_date, site: site, user: notify_user1,
      member_custom_group_ids: [custom_group1.id, custom_group2.id])
  end

  let!(:custom_group1) do
    create :gws_custom_group, name: "#{site.name}/#{unique_id}",
    user_ids: [notify_user1.id, silence_user.id]
  end
  let!(:custom_group2) do
    create :gws_custom_group, name: "#{site.name}/#{unique_id}",
    user_ids: [notify_user2.id]
  end

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!

    stub_request(:post, "https://slack.com/api/auth.test").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/auth_test1.json"), headers: {})

    stub_request(:post, "https://slack.com/api/conversations.list").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/gws/notice/conversation_list.json"), headers: {})

    stub_request(:any, "https://slack.com/api/chat.postMessage").to_return do |request|
      requests << request.as_json.dup
      { status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/gws/circular/post_message.json"),
      headers: {'Content-Type' => 'application/json'} }
    end

    site.slack_oauth_token = unique_id
    site.save!
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect! if @net_connect_allowed
  end

  context '通知オフのユーザー（silence_user）・無関係ユーザー（notify_user3）に通知がいかないこと' do
    it "参加ユーザー" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_member.id)

      expect(Job::Log.count).to eq 2 #let(:post_○○)でjobが実行されてしまう
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        expect(request["body"].slice(/channel=.*&/)).not_to include(silence_user.send_notice_slack_id)
        expect(request["body"].slice(/channel=.*&/)).not_to include(notify_user3.send_notice_slack_id)
      end
    end

    it "参加グループ" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_custom_group.id)

      expect(Job::Log.count).to eq 2
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        expect(request["body"].slice(/channel=.*&/)).not_to include(silence_user.send_notice_slack_id)
        expect(request["body"].slice(/channel=.*&/)).not_to include(notify_user3.send_notice_slack_id)
      end
    end

    it "参加カスタムグループ" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_custom_group.id)

      expect(Job::Log.count).to eq 2
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        expect(request["body"].slice(/channel=.*&/)).not_to include(silence_user.send_notice_slack_id)
        expect(request["body"].slice(/channel=.*&/)).not_to include(notify_user3.send_notice_slack_id)
      end
    end
  end

  context '通知オンのユーザー（notify_user1）に通知が行くこと' do
    it "参加ユーザー" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_member.id)

      expect(Job::Log.count).to eq 2 #let(:post_○○)でjobが実行されてしまう
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        next if !request["body"].slice(/channel=.*&/).include?(notify_user1.send_notice_slack_id.to_s)
        expect(request["body"].slice(/channel=.*&/)).to include(notify_user1.send_notice_slack_id)
      end
    end

    it "参加グループ" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_custom_group.id)

      expect(Job::Log.count).to eq 2
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        next if !request["body"].slice(/channel=.*&/).include?(notify_user1.send_notice_slack_id.to_s)
        expect(request["body"].slice(/channel=.*&/)).to include(notify_user1.send_notice_slack_id)
      end
    end

    it "参加カスタムグループ" do
      job = Gws::Circular::SlackNotificationJob.bind("site_id" => site.id)
      job.perform_now(post_custom_group.id)

      expect(Job::Log.count).to eq 2
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      requests.each do |request|
        next if !request["body"].slice(/channel=.*&/).include?(notify_user1.send_notice_slack_id.to_s)
        expect(request["body"].slice(/channel=.*&/)).to include(notify_user1.send_notice_slack_id)
      end
    end
  end
end
