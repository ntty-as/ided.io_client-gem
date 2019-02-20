require "spec_helper"

RSpec.describe IdedClient::Credential do
  subject { described_class.new(access_token: access_token, credential_key: rsa_public) }
  let(:rsa_private) { OpenSSL::PKey::RSA.generate 2048 }
  let(:rsa_public) { rsa_private.public_key }

  # This payload should be the same as what ided.io returns in the JWT.
  let(:payload) { {sub: "bob-mc-tester", exp: Time.now.to_i + 1000} }
  let(:access_token) { JWT.encode payload, rsa_private, "RS512" }

  describe "#user_id" do
    it "exposes the user_id from the token" do
      expect(subject.user_id).to eql("bob-mc-tester")
    end
  end
end
