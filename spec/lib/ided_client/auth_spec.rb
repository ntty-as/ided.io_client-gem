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

  describe "#exchange_code_for_credential" do
    let(:code) { "i like cheese" }
    let(:token) { "dummy-token" }
    let(:refresh_token) { "dummy-refresh-token"}
    let(:response) {
      {
        "token_type" => "Bearer",
        "created_at" => 1550655570,
        :access_token => token,
        :refresh_token => refresh_token,
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
      expect(credential.refresh_token).to eql("dummy-refresh-token")
    end
  end

  describe "#authorize_url" do
    it "generates the expected URL" do
      expect(subject.authorize_url).to eql(
        "https://ided.localhost/oauth/authorize?client_id=pizza&redirect_uri=https%3A%2F%2Ftest.localhost&response_type=code"
      )
    end
  end

  describe "#exchange_refresh_token" do
    let(:token) { "dummy-token" }
    let(:refresh_token) { "dummy-refresh-token" }
    let(:response) {
      {
        "token_type" => "Bearer",
        "created_at" => 1550655570,
        :access_token => token,
        :refresh_token => refresh_token,
        :expires_at => 1550662770,
      }
    }

    before do
      stub_request(:post, "https://ided.localhost/oauth/token")
        .with(
          body: {
            "client_id" => "pizza",
            "client_secret" => "chips",
            "refresh_token" => "i like fresh cheese",
            "grant_type" => "refresh_token"
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

    it "exchanges a refresh token for a credential" do
      credential = subject.exchange_refresh_token("i like fresh cheese")
      expect(credential.access_token).to eql("dummy-token")
      expect(credential.refresh_token).to eql("dummy-refresh-token")
    end
  end
end
