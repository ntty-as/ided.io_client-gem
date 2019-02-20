require "oauth2"

module IdedClient
  class Auth
    def initialize(ided_host:, client_id:, client_secret:, redirect_uri:)
      @ided_host = ided_host
      @client_id = client_id
      @client_secret = client_secret
      @redirect_uri = redirect_uri
    end

    def exchange_code_for_credentials(code)
      oauth_client.auth_code.get_token(
        code,
        redirect_uri: redirect_uri,
      ).to_hash
    end

    private

    attr_reader :ided_host, :client_id, :client_secret, :redirect_uri

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(client_id, client_secret, site: ided_host)
    end
  end
end
