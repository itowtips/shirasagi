require 'spec_helper'

describe Member::Renderer::GroupInvitation, dbscope: :example do
  let(:site) { cms_site }
  let(:admin_member) { create(:cms_member) }
  let(:group_name) { unique_id }
  let(:invitation_message) { unique_id }
  let(:sender_name) { unique_id }
  let(:node) { create(:member_node_my_group, sender_name: sender_name, sender_email: "#{sender_name}@example.jp") }
  let(:group) do
    Member::Group.create(
      cur_site: site,
      cur_node: node,
      name: group_name,
      invitation_message: invitation_message,
      in_admin: admin_member)
  end
  let(:member1) { create(:cms_member) }

  describe 'render #{sender_name}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{sender_name}')
    end
    it { is_expected.to eq admin_member.name }
  end

  describe 'render #{sender_email}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{sender_email}')
    end
    it { is_expected.to eq admin_member.email }
  end

  describe 'render #{group_name}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{group_name}')
    end
    it { is_expected.to eq group.name }
  end

  describe 'render #{invitation_message}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{invitation_message}')
    end
    it { is_expected.to eq group.invitation_message }
  end

  describe 'render #{accept_url}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{accept_url}')
    end
    it { is_expected.to eq "#{node.full_url}#{group.id}/accept" }
  end

  describe 'render #{reject_url}' do
    subject do
      described_class.render(node: node, group: group, sender: admin_member, recipent: member1, template: '#{reject_url}')
    end
    it { is_expected.to eq "#{node.full_url}#{group.id}/reject" }
  end
end
