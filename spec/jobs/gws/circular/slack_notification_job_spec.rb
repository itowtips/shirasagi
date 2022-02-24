require 'spec_helper'

describe Gws::Circular::SlackNotificationJob, dbscope: :example do
  let(:requests) { [] }
  let!(:site) { Gws::Group.create(name: "シラサギ市") }
  let(:group1) { create :cms_group, name: "#{site.name}/#{unique_id}" }
  let(:group2) { create :cms_group, name: "#{site.name}/#{unique_id}" }
  let(:group3) { create :cms_group, name: "#{site.name}/#{unique_id}" }

  let!(:notify_user1) do
    create(:gws_user, group_ids: [ group1.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U01NOTIFY01')
  end
  let!(:notify_user2) do
    create(:gws_user, group_ids: [ group2.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U02NOTIFY01')
  end
  let!(:notify_user3) do
    create(:gws_user, group_ids: [ group1.id, group2.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U03NOTIFY01')
  end
  let!(:notify_user4) do
    create(:gws_user, group_ids: [ group3.id ], notice_circular_slack_user_setting: 'notify',
      send_notice_slack_id: 'U04NOTIFY01')
  end
  let!(:silence_user) do
    create(:gws_user, group_ids: [ group1.id ], notice_circular_slack_user_setting: 'silence',
      send_notice_slack_id: 'U03SILENCE')
  end

  let!(:custom_group1) do
    create :gws_custom_group, name: "#{site.name}/#{unique_id}",
    user_ids: [notify_user1.id, silence_user.id]
  end
  let!(:custom_group2) do
    create :gws_custom_group, name: "#{site.name}/#{unique_id}",
    user_ids: [notify_user1.id, notify_user2.id]
  end

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!

    requests.clear

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

  context "参加ユーザー" do
    let(:post_member) do
      create(:gws_circular_post, :due_date, site: site, user: notify_user1,
            member_ids: [notify_user1.id, notify_user2.id, silence_user.id])
    end

    before do
      # after_save で Gws::Circular::SlackNotificationJob が実行される
      perform_enqueued_jobs { post_member }
    end

    it do
      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      expect(requests.length).to eq 2

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      # 通知が重複して送られないこと（uniq しても requests.length と同じなら重複していないとみなす）
      channels.uniq!
      expect(channels.length).to eq requests.length
      # 通知オンのユーザー（notify_user1, notify_user2）に通知が行くこと
      expect(channels).to include(*[ notify_user1, notify_user2 ].map(&:send_notice_slack_id))
      # 通知オフのユーザー（silence_user）・無関係ユーザー（notify_user3, notify_user4）に通知がいかないこと
      expect(channels).not_to include(*[ silence_user, notify_user3, notify_user4 ].map(&:send_notice_slack_id))
    end
  end

  context "参加グループ（無関係ユーザー → notify_user4）" do
    let(:post_group) do
      create(:gws_circular_post, :due_date, site: site, user: notify_user1,
             member_group_ids: [group1.id, group2.id])
    end

    before do
      # after_save で Gws::Circular::SlackNotificationJob が実行される
      perform_enqueued_jobs { post_group }
    end

    it do
      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 3件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      expect(requests.length).to eq 3

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      # 通知が重複して送られないこと（uniq しても requests.length と同じなら重複していないとみなす）
      channels.uniq!
      expect(channels.length).to eq requests.length
      # 通知オンのユーザー（notify_user1, notify_user2, notify_user3）に通知が行くこと
      expect(channels).to include(*[ notify_user1, notify_user2, notify_user3 ].map(&:send_notice_slack_id))
      # 通知オフのユーザー（silence_user）・無関係ユーザー（notify_user4）に通知がいかないこと
      expect(channels).not_to include(silence_user.send_notice_slack_id, notify_user4.send_notice_slack_id)
    end
  end

  context "参加カスタムグループ" do
    let(:post_custom_group) do
      create(:gws_circular_post, :due_date, site: site, user: notify_user1,
             member_custom_group_ids: [custom_group1.id, custom_group2.id])
    end

    before do
      # after_save で Gws::Circular::SlackNotificationJob が実行される
      perform_enqueued_jobs { post_custom_group }
    end

    it do
      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      expect(requests.length).to eq 2

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      # 通知が重複して送られないこと（uniq しても requests.length と同じなら重複していないとみなす）
      channels.uniq!
      expect(channels.length).to eq requests.length
      # 通知オンのユーザー（notify_user1, notify_user2）に通知が行くこと
      expect(channels).to include(*[ notify_user1, notify_user2 ].map(&:send_notice_slack_id))
      # 通知オフのユーザー（silence_user）・無関係ユーザー（notify_user3, notify_user4）に通知がいかないこと
      expect(channels).not_to include(*[ silence_user, notify_user3, notify_user4 ].map(&:send_notice_slack_id))
    end
  end

  context "全ての参加者フィールド" do
    let(:post_duplicate_user) do
      create(:gws_circular_post, :due_date, site: site, user: notify_user1,
             member_ids: [notify_user1.id, notify_user2.id, notify_user3.id, notify_user3.id],
             member_custom_group_ids: [custom_group1.id, custom_group2.id],
             member_group_ids: [group1.id, group2.id]
      )
    end

    before do
      # after_save で Gws::Circular::SlackNotificationJob が実行される
      perform_enqueued_jobs { post_duplicate_user }
    end

    it do
      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 3件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      expect(requests.length).to eq 3

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      # 通知が重複して送られないこと（uniq しても requests.length と同じなら重複していないとみなす）
      channels.uniq!
      expect(channels.length).to eq requests.length
      # 通知オンのユーザー（notify_user1, notify_user2, notify_user3）に通知が行くこと
      expect(channels).to include(*[ notify_user1, notify_user2, notify_user3 ].map(&:send_notice_slack_id))
      # 通知オフのユーザー（silence_user）・無関係ユーザー（notify_user4）に通知がいかないこと
      expect(channels).not_to include(silence_user.send_notice_slack_id, notify_user4.send_notice_slack_id)
    end
  end

  context "notify_user5 の slack_id が notify_user1 と同じ" do
    let!(:notify_user5) do
      create(:gws_user, group_ids: [ group1.id ], notice_circular_slack_user_setting: 'notify',
             send_notice_slack_id: notify_user1.send_notice_slack_id)
    end
    let(:post_member2) do
      create(:gws_circular_post, :due_date, site: site, user: notify_user1,
             member_ids: [notify_user1.id, notify_user2.id, notify_user5.id, silence_user.id])
    end

    before do
      # after_save で Gws::Circular::SlackNotificationJob が実行される
      perform_enqueued_jobs { post_member2 }
    end

    it do
      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/DM通知成功件数: 2件、DM通知失敗件数: 0件/)
        expect(log.logs).to include(/チャンネル通知成功件数: 0件、チャンネル通知失敗件数: 0件/)
      end

      expect(requests.length).to eq 2

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      # 通知が重複して送られないこと（uniq しても requests.length と同じなら重複していないとみなす）
      channels.uniq!
      expect(channels.length).to eq requests.length
      # 通知オンのユーザー（notify_user1, notify_user2）に通知が行くこと
      expect(channels).to include(*[ notify_user1, notify_user2 ].map(&:send_notice_slack_id))
      # 通知オフのユーザー（silence_user）・無関係ユーザー（notify_user3, notify_user4）に通知がいかないこと
      expect(channels).not_to include(*[ silence_user, notify_user3, notify_user4 ].map(&:send_notice_slack_id))
    end
  end
end
