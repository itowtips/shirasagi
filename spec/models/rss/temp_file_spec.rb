require 'spec_helper'

describe Rss::TempFile, dbscope: :example do
  describe '.create_from_post' do
    let(:site) { cms_site }
    let(:file) { Rails.root.join(*%w(spec fixtures rss sample-atom.xml)) }
    let(:payload) { File.read(file) }
    let(:content_type) { 'application/xml+rss' }
    subject { described_class.create_from_post(site, payload, content_type) }

    its(:id) { is_expected.to be > 0 }
    its(:model) { is_expected.to eq 'ss/temp_file' }
    its(:state) { is_expected.to eq 'closed' }
    its(:name) { is_expected.not_to be_nil }
    its(:filename) { is_expected.not_to be_nil }
    its(:size) { is_expected.to be > 0 }
    its(:content_type) { is_expected.to eq content_type }
    its(:site) { is_expected.not_to be_nil }
  end
end
