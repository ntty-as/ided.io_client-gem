require "spec_helper"

RSpec.describe IdedClient::Auth do
  subject { described_class.new(args) }

  let(:args) {
    {
      ided_host: ided_host,
      redirect_uri: redirect_uri,
      client_id: client_id,
      client_secret: client_secret,
      credential_key: "fake key",
    }
  }
  let(:ided_host) { "https://ided.localhost" }
  let(:redirect_uri) { "https://test.localhost" }
  let(:client_id) { "pizza" }
  let(:client_secret) { "chips" }
  let(:code) { "i like cheese" }
  let(:token) { "dummy-token" }
  let(:response) {
    {
      "token_type" => "Bearer",
      "created_at" => 1550655570,
      :access_token => token,
      :refresh_token => nil,
      :expires_at => 1550662770,
    }
  }

  before do
    stub_request(:post, "https://ided.localhost/oauth/token")
      .with(
        body: {
          "client_id" => "pizza",
          "client_secret" => "chips",
          "code" => "i like cheese",
          "grant_type" => "authorization_code",
          "redirect_uri" => "https://test.localhost",
        },
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
        },
      ).to_return(
        status: 200,
        body: response.to_json,
        headers: { 'Content-Type': "application/json" },
      )
  end

  it "allows for the auth code to be exchanged for a token" do
    credential = subject.exchange_code_for_credential(code)
    expect(credential.access_token).to eql("dummy-token")
  end
end
