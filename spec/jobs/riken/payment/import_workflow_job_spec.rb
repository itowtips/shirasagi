require 'spec_helper'

describe Riken::Payment::ImportWorkflowJob, dbscope: :example do
  let!(:site) { gws_site }
  let!(:user) { gws_user }
  let!(:riken_user) { create :gws_user, uid: Riken.encrypt("XTS91L"), group_ids: user.group_ids }
  let!(:setting) { create(:riken_payment_importer_setting) }

  let(:token_url) { setting.token_url }
  let(:token_body) do
    {
      access_token: unique_id,
      token_type: "Bearer",
      expires_in: 3600
    }.to_json
  end
  let(:api_url) { setting.api_url }
  let(:api_body) { [workflow.api_attributes].to_json }

  before do
    WebMock.stub_request(:post, token_url).to_return(status: 200, body: token_body)
    WebMock.stub_request(:post, api_url).to_return(status: 200, body: api_body)
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect!
  end

  context "import request workflow" do
    let!(:workflow) do
      create(:riken_payment_workflow_sample, status: "0", proxy_id: Riken.decrypt(riken_user.uid))
    end

    it do
      expect(Gws::Circular::Post.site(site).count).to eq 0

      # first import
      described_class.bind(site_id: site.id).perform_now
      expect(Gws::Circular::Post.site(site).count).to eq 1

      item = Gws::Circular::Post.site(site).first
      expect(item).not_to eq nil
      expect(item.name).to eq setting.request_title
      expect(item.text).to include("代理決裁申請の承認依頼が届いています。")
      expect(item.text).to include(workflow.url)
      expect(item.text_type).to eq "cke"
      expect(item.riken_workflow_id).to eq workflow.workflow_id
      expect(item.riken_workflow_status).to eq workflow.status
      expect(item.riken_workflow_update_time).to eq workflow.update_time
      expect(item.state).to eq "public"
      expect(item.user_id).to eq user.id
      expect(item.user_ids).to eq [user.id, riken_user.id]
      expect(item.member_ids).to eq [riken_user.id]

      # second import
      described_class.bind(site_id: site.id).perform_now
      expect(Gws::Circular::Post.site(site).count).to eq 1

      item = Gws::Circular::Post.site(site).first
      expect(item).not_to eq nil
      expect(item.name).to eq setting.request_title
      expect(item.text).to include("代理決裁申請の承認依頼が届いています。")
      expect(item.text).to include(workflow.url)
      expect(item.text_type).to eq "cke"
      expect(item.riken_workflow_id).to eq workflow.workflow_id
      expect(item.riken_workflow_status).to eq workflow.status
      expect(item.riken_workflow_update_time).to eq workflow.update_time
      expect(item.state).to eq "public"
      expect(item.user_id).to eq user.id
      expect(item.user_ids).to eq [user.id, riken_user.id]
      expect(item.member_ids).to eq [riken_user.id]
    end
  end

  context "import remand workflow" do
    let!(:workflow) do
      create(:riken_payment_workflow_sample, status: "1", create_id: Riken.decrypt(riken_user.uid))
    end

    it do
      expect(Gws::Circular::Post.site(site).count).to eq 0

      # first import
      described_class.bind(site_id: site.id).perform_now
      expect(Gws::Circular::Post.site(site).count).to eq 1

      item = Gws::Circular::Post.site(site).first
      expect(item).not_to eq nil
      expect(item.name).to eq setting.remand_title
      expect(item.text).to include("代理決裁申請の差し戻しが届いています。")
      expect(item.text).to include(workflow.url)
      expect(item.text_type).to eq "cke"
      expect(item.riken_workflow_id).to eq workflow.workflow_id
      expect(item.riken_workflow_status).to eq workflow.status
      expect(item.riken_workflow_update_time).to eq workflow.update_time
      expect(item.state).to eq "public"
      expect(item.user_id).to eq user.id
      expect(item.user_ids).to eq [user.id, riken_user.id]
      expect(item.member_ids).to eq [riken_user.id]

      # second import
      described_class.bind(site_id: site.id).perform_now
      expect(Gws::Circular::Post.site(site).count).to eq 1

      item = Gws::Circular::Post.site(site).first
      expect(item).not_to eq nil
      expect(item.name).to eq setting.remand_title
      expect(item.text).to include("代理決裁申請の差し戻しが届いています。")
      expect(item.text).to include(workflow.url)
      expect(item.text_type).to eq "cke"
      expect(item.riken_workflow_id).to eq workflow.workflow_id
      expect(item.riken_workflow_status).to eq workflow.status
      expect(item.riken_workflow_update_time).to eq workflow.update_time
      expect(item.state).to eq "public"
      expect(item.user_id).to eq user.id
      expect(item.user_ids).to eq [user.id, riken_user.id]
      expect(item.member_ids).to eq [riken_user.id]
    end
  end
end
