require 'spec_helper'

describe Riken::MS365::GraphApi, dbscope: :example do
  let(:site) do
    create :gws_group, riken_ms365_tenant_id: unique_id, riken_ms365_client_id: unique_id, in_riken_ms365_client_secret: unique_id
  end

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect! if @net_connect_allowed
  end

  describe ".each_room" do
    context "usual case" do
      before do
        stub_request(:post, "https://login.microsoftonline.com/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token").
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_token1.json"), headers: {})
        stub_request(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.room").
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_rooms1.json"), headers: {})
      end

      it do
        rooms = []
        Riken::MS365::GraphApi.each_room(site) do |room|
          rooms << room
        end
        expect(rooms.length).to eq 2
      end
    end

    context "timeouts" do
      before do
        stub_request(:post, "https://login.microsoftonline.com/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token").
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_token1.json"), headers: {})
        stub_request(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.room").
          to_timeout.
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_rooms1.json"), headers: {})
      end

      it do
        rooms = []
        Riken::MS365::GraphApi.each_room(site) do |room|
          rooms << room
        end
        expect(rooms.length).to eq 2
      end
    end

    context "invalid_authentication_token" do
      before do
        token_resp = ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_invalid_authentication_token1.json")

        stub_request(:post, "https://login.microsoftonline.com/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token").
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_token1.json"), headers: {})
        stub_request(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.room").
          to_return(status: 401, body: token_resp, headers: {}).
          to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_rooms1.json"), headers: {})
      end

      it do
        rooms = []
        Riken::MS365::GraphApi.each_room(site) do |room|
          rooms << room
        end
        expect(rooms.length).to eq 2
      end
    end
  end

  describe ".each_room_list" do
    before do
      stub_request(:post, "https://login.microsoftonline.com/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token").
        to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_token1.json"), headers: {})
      stub_request(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.roomlist").
        to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_room_lists1.json"), headers: {})
    end

    it do
      room_lists = []
      Riken::MS365::GraphApi.each_room_list(site) do |room_list|
        room_lists << room_list
      end
      expect(room_lists.length).to eq 1
    end
  end

  describe ".each_event" do
    let(:room_id) { unique_email }

    before do
      stub_request(:post, "https://login.microsoftonline.com/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token").
        to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_token1.json"), headers: {})
      stub_request(:get, "https://graph.microsoft.com/v1.0/users/#{room_id}/events").
        to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/ms365_events1.json"), headers: {})
    end

    it do
      events = []
      Riken::MS365::GraphApi.each_event(site, room_id) do |event|
        events << event
      end
      expect(events.length).to eq 1
    end
  end
end
