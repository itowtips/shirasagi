require 'spec_helper'

describe "Rss::Agents::Nodes::PubSubHubbubController", type: :request, dbscope: :example do
  let(:site) { cms_site }

  context "general case" do
    let(:node) { create(:rss_node_pub_sub_hubbub, cur_site: site) }
    let(:subscriber_path) { "#{node.url}subscriber" }
    let(:challenge) { "1234567890" }

    describe "GET /subscriber" do
      before do
        get(
          "#{subscriber_path}?hub.mode=subscribe&hub.topic=http://example.org/&hub.challenge=#{challenge}",
          {},
          { 'HTTP_HOST' => site.domain })
      end

      it do
        expect(response.status).to eq 200
        expect(response.body).to eq challenge
      end
    end

    describe "POST /subscriber" do
      let(:file) { Rails.root.join(*%w(spec fixtures rss sample-atom.xml)) }
      let(:payload) { File.read(file) }
      let(:content_type) { 'application/xml+rss' }

      before do
        # To stabilize spec, rss import job is executed in-place process .
        allow(SS::RakeRunner).to receive(:run_async).and_wrap_original do |_, *args|
          config = { name: "default", model: "job:service", num_workers: 0, poll: %w(default voice_synthesis) }
          config.stringify_keys!
          Job::Service.run config
        end
      end

      before do
        post(
          subscriber_path,
          {},
          { 'HTTP_HOST' => site.domain, 'RAW_POST_DATA' => payload, 'CONTENT_TYPE' => content_type })
      end

      it do
        expect(response.status).to eq 200
        expect(response.body).to eq ''
        expect(Rss::Page.count).to eq 5
      end
    end
  end

  context "specific topic only" do
    let(:node) { create(:rss_node_pub_sub_hubbub, cur_site: site, topic_urls: 'http://example.org/topic1.xml') }
    let(:subscriber_path) { "#{node.url}subscriber" }
    let(:challenge) { "1234567890" }

    describe "subscribe allowed topis" do
      before do
        get(
          "#{subscriber_path}?hub.mode=subscribe&hub.topic=http://example.org/topic1.xml&hub.challenge=#{challenge}",
          {},
          { 'HTTP_HOST' => site.domain })
      end

      it do
        expect(response.status).to eq 200
        expect(response.body).to eq challenge
      end
    end

    describe "subscribe unallowed topis" do
      before do
        get(
          "#{subscriber_path}?hub.mode=subscribe&hub.topic=http://example.org/topic2.xml&hub.challenge=#{challenge}",
          {},
          { 'HTTP_HOST' => site.domain })
      end

      it do
        expect(response.status).to eq 404
        expect(response.body).to eq ''
      end
    end
  end

  context "hmac digest" do
    let(:secret) { '0987654321' }
    let(:node) { create(:rss_node_pub_sub_hubbub, cur_site: site, secret: secret) }
    let(:subscriber_path) { "#{node.url}subscriber" }
    let(:challenge) { "1234567890" }
    let(:file) { Rails.root.join(*%w(spec fixtures rss sample-atom.xml)) }
    let(:payload) { File.read(file) }
    let(:content_type) { 'application/xml+rss' }

    before do
      # To stabilize spec, rss import job is executed in-place process .
      allow(SS::RakeRunner).to receive(:run_async).and_wrap_original do |_, *args|
        config = { name: "default", model: "job:service", num_workers: 0, poll: %w(default voice_synthesis) }
        config.stringify_keys!
        Job::Service.run config
      end
    end

    before do
      header = {
        'HTTP_HOST' => site.domain,
        'RAW_POST_DATA' => payload,
        'CONTENT_TYPE' => content_type,
        'X-Hub-Signature' => "sha1=#{digest}" }

      post(subscriber_path, {}, header)
    end

    describe "valid hmac signature present" do
      let(:digest) { OpenSSL::HMAC.hexdigest('sha1', secret, payload) }

      it do
        expect(response.status).to eq 200
        expect(response.body).to eq ''
        expect(Rss::Page.count).to eq 5
      end
    end

    describe "invalid hmac signature present" do
      let(:digest) { OpenSSL::HMAC.hexdigest('sha1', secret, 'abcdefg') }

      it do
        expect(response.status).to eq 200
        expect(response.body).to eq ''
        expect(Rss::Page.count).to eq 0
      end
    end
  end
end
