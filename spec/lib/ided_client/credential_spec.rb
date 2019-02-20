require "spec_helper"

RSpec.describe IdedClient::Credential do
  subject { described_class.new(access_token: access_token, credential_key: rsa_public) }
  let(:rsa_private) { OpenSSL::PKey::RSA.generate 2048 }
  let(:rsa_public) { rsa_private.public_key }

  # This payload should be the same as what ided.io returns in the JWT.
  let(:payload) { { sub: "bob-mc-tester", exp: exp } }
  let(:exp) { Time.now.to_i + 1000 }
  let(:access_token) { JWT.encode payload, rsa_private, "RS512" }

  describe "#user_id" do
    it "exposes the user_id from the token" do
      expect(subject.user_id).to eql("bob-mc-tester")
    end
  end

  describe "#expired?" do
    it "is not expired when the expiry is in the future" do
      expect(subject.expired?).to be(false)
    end

    context "expiry is in the past" do
      let(:exp) { Time.parse("2018-01-01T12:00") }

      it "has expired" do
        expect(subject.expired?).to be(true)
      end
    end
  end
end
