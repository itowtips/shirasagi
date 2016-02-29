require 'spec_helper'

describe "cms_apis_members", dbscope: :example do
  let(:site) { cms_site }

  context "select multiple members" do
    let(:index_path) { cms_apis_members_path site.id }

    it "without login" do
      visit index_path
      expect(current_path).to eq sns_login_path
    end

    it "without auth" do
      login_ss_user
      visit index_path
      expect(status_code).to eq 403
    end

    context "with auth" do
      before do
        10.times.each do
          create(:cms_member)
        end
        login_cms_user
      end

      it "#index" do
        visit index_path
        expect(status_code).to eq 200
        expect(current_path).to eq index_path
        expect(page).to have_css('tbody.items td.checkbox')
        expect(page).to have_css('button.select-items')
      end
    end
  end

  context "select single member" do
    let(:index_path) { cms_apis_members_path site.id }

    before do
      10.times.each do
        create(:cms_member)
      end
      login_cms_user
    end

    it "#index" do
      visit "#{index_path}?single=1"
      expect(status_code).to eq 200
      expect(current_path).to eq index_path
      expect(page).not_to have_css('tbody.items td.checkbox')
      expect(page).to have_css('button.select-items')
    end
  end
end
