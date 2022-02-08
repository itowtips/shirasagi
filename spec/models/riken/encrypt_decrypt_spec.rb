require 'spec_helper'

describe Riken, dbscope: :example do
  describe "#encrypt" do
    context "usual case" do
      let(:rk_uid) { "abc" }

      it do
        encrypted = Riken.encrypt(rk_uid)
        expect(/^[0-9a-z]+$/.match?(encrypted)).to be_truthy

        decrypted = Riken.decrypt(encrypted)
        expect(decrypted).to eq rk_uid
        expect(decrypted.encoding.to_s).to eq rk_uid.encoding.to_s
      end
    end

    context "with empty string" do
      it do
        expect(Riken.encrypt("")).to be_blank
        expect(Riken.decrypt("")).to be_blank
      end
    end

    context "with nil" do
      it do
        expect(Riken.encrypt(nil)).to be_nil
        expect(Riken.decrypt(nil)).to be_nil
      end
    end
  end
end
