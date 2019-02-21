require "spec_helper"

RSpec.describe IdedClient::Team do
  subject { described_class.new }

  describe ".with_credential" do
    let(:credential) { IdedClient::Credential.new(access_token: "pizza", credential_key: "fake") }

    before do
      IdedClient::BaseResource.site = "http://ided.localhost"
      stub_request(:get, "http://ided.localhost/teams")
        .with(
          headers: {
            "Accept" => "application/vnd.api+json",
            "Authorization" => "Bearer pizza",
          },
        ).
        to_return(status: 200, body: '{"data": [{}]}', headers: { "Content-Type": "application/vnd.api+json" })
    end

    it "includes the access token in the request" do
      teams = []
      described_class.with_credential(credential) do
        teams = described_class.all
      end
      expect(teams.count).to eql(1)
    end
  end
end
