require "spec_helper"

RSpec.describe IdedClient::Wrapper do
  subject { described_class.new }

  describe "#credential_from_request" do
    let(:request) { double(headers: headers) }
    let(:cred) { double(cred) }
    let(:headers) { { "Authorization" => "Bearer pizza" } }

    before do
      allow(subject).to receive(:credential_key).and_return("fake key")
    end

    it "builds the credential from the authorization header" do
      expect(subject.credential_from_request(request).access_token).to eql("pizza")
    end

    context "there is no authorization header" do
      let(:headers) { {} }

      it "returns nil" do
        expect(subject.credential_from_request(request)).to eql(nil)
      end
    end
  end
end
