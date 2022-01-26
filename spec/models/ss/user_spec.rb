require 'spec_helper'

describe SS::User, dbscope: :example do
  let(:model) { SS::User }

  describe "#save" do
    let(:group) { ss_group }

    context "when name is missing" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          email: "u#{r}@example.jp",
          password: SS::Crypt.crypt("p#{r}"),
          group_ids: [ group.id ]
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when uid and email is missing" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          password: SS::Crypt.crypt("p#{r}"),
          group_ids: [ group.id ]
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when uid containing '@' is given" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          password: SS::Crypt.crypt("p#{r}"),
          group_ids: [ group.id ],
          uid: "u#{r}@example.jp"
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when password is missing" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          email: "u#{r}@example.jp",
          group_ids: [ group.id ]
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when invalid type is givin" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          email: "u#{r}@example.jp",
          password: SS::Crypt.crypt("p#{r}"),
          type: "t#{r}",
          group_ids: [ group.id ]
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when two user having same email is given" do
      r0 = rand(0x100000000).to_s(36)
      r1= rand(0x100000000).to_s(36)
      r2 = rand(0x100000000).to_s(36)

      let(:entity1) do
        {
          name: "u#{r1}",
          email: "u#{r0}@example.jp",
          password: SS::Crypt.crypt("p#{r1}"),
          group_ids: [ group.id ]
        }
      end
      let(:entity2) do
        {
          name: "u#{r2}",
          email: "u#{r0}@example.jp",
          password: SS::Crypt.crypt("p#{r2}"),
          group_ids: [ group.id ]
        }
      end

      it do
        expect { model.new(entity1).save! }.not_to raise_error
        expect { model.new(entity2).save! }.to raise_error Mongoid::Errors::Validations
      end
    end

    context "when valid sns user is given" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          email: "u#{r}@example.jp",
          password: SS::Crypt.crypt("p#{r}"),
          type: "sns",
          group_ids: [ group.id ]
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.not_to raise_error
      end
    end

    context "when valid ldap user is given" do
      r = rand(0x100000000).to_s(36)
      let(:entity) do
        {
          name: "u#{r}",
          type: "ldap",
          group_ids: [ group.id ],
          uid: "u#{r}",
          ldap_dn: "cn=u#{r},dc=example,dc=jp"
        }
      end
      subject { model.new(entity) }

      it do
        expect { subject.save! }.not_to raise_error
      end
    end
  end

  describe ".and_enabled" do
    let(:now) { Time.zone.now }

    context "account_start_date is nil" do
      context "account_expiration_date is nil" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is enabled") { expect(model.first.enabled?).to be_truthy }
        it("exists only one enabled item") { expect(model.and_enabled.count).to eq 1 }
      end

      context "account_expiration_date is future date" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_expiration_date: now + 7.days
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is enabled") { expect(model.first.enabled?).to be_truthy }
        it("exists only one enabled item") { expect(model.and_enabled.count).to eq 1 }
      end

      context "account_expiration_date is past date" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_expiration_date: now - 7.days
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is disabled") { expect(model.first.enabled?).to be_falsey }
        it("exists no enabled items") { expect(model.and_enabled.count).to eq 0 }
      end
    end

    context "account_start_date is past date" do
      context "account_expiration_date is nil" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_start_date: now - 7.days
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is enabled") { expect(model.first.enabled?).to be_truthy }
        it("exists only one enabled item") { expect(model.and_enabled.count).to eq 1 }
      end

      context "account_expiration_date is future date" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_start_date: now - 7.days,
            account_expiration_date: now + 7.days
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is enabled") { expect(model.first.enabled?).to be_truthy }
        it("exists only one enabled item") { expect(model.and_enabled.count).to eq 1 }
      end

      context "account_expiration_date is past date" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_start_date: now - 7.days,
            account_expiration_date: now - 3.days
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is disabled") { expect(model.first.enabled?).to be_falsey }
        it("exists no enabled items") { expect(model.and_enabled.count).to eq 0 }
      end
    end

    context "account_start_date is future date" do
      context "account_expiration_date is nil" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_start_date: now + 3.days,
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is disabled") { expect(model.first.enabled?).to be_falsey }
        it("exists no enabled items") { expect(model.and_enabled.count).to eq 0 }
      end

      context "account_expiration_date is future date" do
        let(:entity) do
          {
            uid: unique_id,
            in_password: 'pass',
            name: unique_id,
            account_start_date: now + 3.days,
            account_expiration_date: now + 7.days,
          }
        end
        before { model.create!(entity) }

        it("exists only one item") { expect(model.count).to eq 1 }
        it("is disabled") { expect(model.first.enabled?).to be_falsey }
        it("exists no enabled items") { expect(model.and_enabled.count).to eq 0 }
      end
    end
  end

  describe "#i18n_name" do
    context "when only name is given" do
      it do
        item = SS::User.new(name: unique_id, email: unique_email, password: unique_id)
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
        item = SS::User.new(
          i18n_name_translations: I18n.available_locales.index_with { unique_id },
          email: unique_email, password: unique_id
        )
        expect(item.valid?).to be_truthy
        expect(item.errors).to be_blank
        expect(item.name).to eq item.i18n_name_translations[I18n.default_locale]
      end
    end

    context "when only i18n_name of default locale is given" do
      it do
        item = SS::User.new(
          i18n_name_translations: { I18n.default_locale => unique_id },
          email: unique_email, password: unique_id
        )
        expect(item.valid?).to be_truthy
        expect(item.errors).to be_blank
        expect(item.name).to eq item.i18n_name_translations[I18n.default_locale]
      end
    end

    context "when only i18n_name of alternative locales is given" do
      it do
        item = SS::User.new(
          i18n_name_translations: I18n.available_locales.reject { |lang| lang == I18n.default_locale }.index_with { unique_id },
          email: unique_email, password: unique_id
        )
        expect(item.valid?).to be_falsey
        expect(item.errors[:name]).to have(1).items
        expect(item.errors[:name]).to include(I18n.t("errors.messages.blank"))
        expect(item.name).to be_blank
      end
    end
  end
end
