require "spec_helper"
require "ided_client/test_helpers"

RSpec.describe IdedClient::TestHelpers do
  it "allows a token to be generated and decoded" do
    token = described_class.user_test_token("pizza-id")
    expect(token).to be_present

    payload = JWT.decode token, described_class.public_key, true, { algorithm: "RS512" }
    expect(payload[0]).to include("sub" => "pizza-id")
  end
end
