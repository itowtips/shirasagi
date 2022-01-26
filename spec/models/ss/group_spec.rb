require 'spec_helper'

describe SS::Group, type: :model, dbscope: :example do
  context "blank params" do
    subject { described_class.new.valid? }
    it { expect(subject).to be_falsey }
  end

  context "default params" do
    subject { create :ss_group }
    it { expect(subject.errors.size).to eq 0 }
  end

  context "renaming" do
    context "backward compatibilities" do
      let!(:new_name) { unique_id }

      it do
        root = create(:ss_group, name: unique_id)
        child = create(:ss_group, name: "#{root.name}/#{unique_id}")

        old_name = root.name
        expect(child.name).to start_with("#{old_name}/")

        root = SS::Group.find(root.id)
        root.name = new_name
        root.save!

        child = SS::Group.find(child.id)
        expect(child.name).not_to start_with("#{old_name}/")
        expect(child.name).to start_with(new_name)
      end
    end

    context "with i18n name" do
      context "both langs are changed" do
        it do
          name_ja = unique_id
          name_en = unique_id
          root = create(:ss_group, i18n_name_translations: { ja: name_ja, en: name_en })
          child = create(:ss_group, i18n_name_translations: { ja: "#{name_ja}/#{unique_id}", en: "#{name_en}/#{unique_id}" })

          new_name_ja = unique_id
          new_name_en = unique_id
          root = SS::Group.find(root.id)
          root.i18n_name_translations = { ja: new_name_ja, en: new_name_en }
          root.save!

          child = SS::Group.find(child.id)
          expect(child.i18n_name_translations[:ja]).to start_with("#{new_name_ja}/")
          expect(child.i18n_name_translations[:en]).to start_with("#{new_name_en}/")
          expect(child.name).to start_with("#{new_name_ja}/")
        end
      end

      context "only lang 'ja' is changed" do
        it do
          name_ja = unique_id
          name_en = unique_id
          root = create(:ss_group, i18n_name_translations: { ja: name_ja, en: name_en })
          child = create(:ss_group, i18n_name_translations: { ja: "#{name_ja}/#{unique_id}", en: "#{name_en}/#{unique_id}" })

          new_name_ja = unique_id
          root = SS::Group.find(root.id)
          root.i18n_name_translations = { ja: new_name_ja, en: name_en }
          root.save!

          child = SS::Group.find(child.id)
          expect(child.i18n_name_translations[:ja]).to start_with("#{new_name_ja}/")
          expect(child.i18n_name_translations[:en]).to start_with("#{name_en}/")
          expect(child.name).to start_with("#{new_name_ja}/")
        end
      end

      context "only lang 'en' is changed" do
        it do
          name_ja = unique_id
          name_en = unique_id
          root = create(:ss_group, i18n_name_translations: { ja: name_ja, en: name_en })
          child = create(:ss_group, i18n_name_translations: { ja: "#{name_ja}/#{unique_id}", en: "#{name_en}/#{unique_id}" })

          new_name_en = unique_id
          root = SS::Group.find(root.id)
          root.i18n_name_translations = { ja: name_ja, en: new_name_en }
          root.save!

          child = SS::Group.find(child.id)
          expect(child.i18n_name_translations[:ja]).to start_with("#{name_ja}/")
          expect(child.i18n_name_translations[:en]).to start_with("#{new_name_en}/")
          expect(child.name).to start_with("#{name_ja}/")
        end
      end
    end
  end

  context ".descendants" do
    let!(:root) { create(:ss_group) }
    let!(:group1) { create(:ss_group, name: "#{root.name}/#{unique_id}") }
    let!(:group11) { create(:ss_group, name: "#{group1.name}/#{unique_id}") }
    let!(:group12) { create(:ss_group, name: "#{group1.name}/#{unique_id}") }
    let!(:group2) { create(:ss_group, name: "#{root.name}/#{unique_id}") }
    let!(:group21) { create(:ss_group, name: "#{group2.name}/#{unique_id}") }
    let!(:group22) { create(:ss_group, name: "#{group2.name}/#{unique_id}") }

    it do
      ids = root.descendants.pluck(:id)
      expect(ids).to have(6).items
      expect(ids).to include(group1.id, group11.id, group12.id, group2.id, group21.id, group22.id)
    end

    it do
      ids = group1.descendants.pluck(:id)
      expect(ids).to have(2).items
      expect(ids).to include(group11.id, group12.id)
    end
  end

  context ".descendants_and_self" do
    let!(:root) { create(:ss_group) }
    let!(:group1) { create(:ss_group, name: "#{root.name}/#{unique_id}") }
    let!(:group11) { create(:ss_group, name: "#{group1.name}/#{unique_id}") }
    let!(:group12) { create(:ss_group, name: "#{group1.name}/#{unique_id}") }
    let!(:group2) { create(:ss_group, name: "#{root.name}/#{unique_id}") }
    let!(:group21) { create(:ss_group, name: "#{group2.name}/#{unique_id}") }
    let!(:group22) { create(:ss_group, name: "#{group2.name}/#{unique_id}") }

    it do
      ids = root.descendants_and_self.pluck(:id)
      expect(ids).to have(7).items
      expect(ids).to include(root.id, group1.id, group11.id, group12.id, group2.id, group21.id, group22.id)
    end

    it do
      ids = group1.descendants_and_self.pluck(:id)
      expect(ids).to have(3).items
      expect(ids).to include(group1.id, group11.id, group12.id)
    end
  end

  describe "what ss/group exports to liquid" do
    let(:assigns) { {} }
    let(:registers) { {} }
    subject { group.to_liquid }

    before do
      subject.context = ::Liquid::Context.new(assigns, {}, registers, true)
    end

    context "with root group" do
      let(:name) { unique_id }
      let!(:group) { create(:ss_group, name: name) }

      it do
        expect(subject.name).to eq name
        expect(subject.full_name).to eq name
        expect(subject.section_name).to eq name
        expect(subject.trailing_name).to eq name
        expect(subject.last_name).to eq name
      end
    end

    context "with sub group" do
      let(:names) { Array.new(4) { unique_id } }
      let!(:root_group) { create(:ss_group, name: names.first) }
      let!(:secondary_group) { create(:ss_group, name: names[0..1].join("/")) }
      let!(:group) { create(:ss_group, name: names.join("/")) }

      it do
        expect(subject.name).to eq names.join("/")
        expect(subject.full_name).to eq names.join(" ")
        expect(subject.section_name).to eq names[1..3].join(" ")
        expect(subject.last_name).to eq names[3]

        # trailing_name depends on #depth
        expect(group.depth).to eq 2
        expect(subject.trailing_name).to eq names[2..3].join("/")
      end
    end
  end

  describe "#i18n_name" do
    context "when only name is given" do
      it do
        item = SS::Group.new(name: unique_id)
        expect(item.valid?).to be_truthy
        expect(item.errors).to be_blank
        expect(item.i18n_name).to be_present
        I18n.available_locales.each do |lang|
          expect(item.i18n_name_translations[lang]).to eq item.name
        end
      end
    end

    context "when only i18n_name is given" do
      it do
        item = SS::Group.new(
          i18n_name_translations: I18n.available_locales.index_with { unique_id }
        )
        expect(item.valid?).to be_truthy
        expect(item.errors).to be_blank
        expect(item.name).to eq item.i18n_name_translations[I18n.default_locale]
      end
    end

    context "when only i18n_name of default locale is given" do
      it do
        item = SS::Group.new(
          i18n_name_translations: { I18n.default_locale => unique_id }
        )
        expect(item.valid?).to be_truthy
        expect(item.errors).to be_blank
        expect(item.name).to eq item.i18n_name_translations[I18n.default_locale]
      end
    end

    context "when only i18n_name of alternative locales is given" do
      it do
        item = SS::Group.new(
          i18n_name_translations: I18n.available_locales.reject { |lang| lang == I18n.default_locale }.index_with { unique_id }
        )
        expect(item.valid?).to be_falsey
        expect(item.errors[:name]).to have(1).items
        expect(item.errors[:name]).to include(I18n.t("errors.messages.blank"))
        expect(item.name).to be_blank
      end
    end
  end
end
