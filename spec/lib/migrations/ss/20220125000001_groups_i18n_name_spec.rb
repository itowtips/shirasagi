require 'spec_helper'
require Rails.root.join("lib/migrations/ss/20220125000001_groups_i18n_name.rb")

RSpec.describe SS::Migration20220125000001, dbscope: :example do
  let!(:group1) { create :ss_group }

  before do
    group1.unset(:i18n_name)
    described_class.new.change
  end

  it do
    group1.reload
    expect(group1.i18n_name).to eq group1.name
    group1.i18n_name_translations.each_value do |i18n_name|
      expect(i18n_name).to eq group1.name
    end
  end
end
