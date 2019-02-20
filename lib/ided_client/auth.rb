require "oauth2"

module IdedClient
  class Auth
    def initialize(ided_host:, client_id:, client_secret:, redirect_uri:, credential_key:)
      @ided_host = ided_host
      @client_id = client_id
      @client_secret = client_secret
      @redirect_uri = redirect_uri
      @credential_key = credential_key
    end

    def exchange_code_for_credential(code)
      token = exchange_code(code)
      Credential.new(access_token: token.token, credential_key: credential_key)
    end

    private

    attr_reader :ided_host, :client_id, :client_secret, :redirect_uri, :credential_key

    def exchange_code(code)
      oauth_client.auth_code.get_token(
        code,
        redirect_uri: redirect_uri,
      )
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(client_id, client_secret, site: ided_host)
    end
  end
end
