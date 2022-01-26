require 'spec_helper'
require Rails.root.join("lib/migrations/ss/20220125000000_users_i18n_name.rb")

RSpec.describe SS::Migration20220125000000, dbscope: :example do
  let!(:user1) { create :ss_user }

  before do
    user1.unset(:i18n_name)
    described_class.new.change
  end

  it do
    user1.reload
    expect(user1.i18n_name).to eq user1.name
    user1.i18n_name_translations.each_value do |i18n_name|
      expect(i18n_name).to eq user1.name
    end
  end
end
