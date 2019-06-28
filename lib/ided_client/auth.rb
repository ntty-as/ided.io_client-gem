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
      build_credential(access_token: token.token, refresh_token: token.refresh_token)
    end

    def authorize_url
      oauth_client.auth_code.authorize_url(redirect_uri: redirect_uri)
    end

    def build_credential(access_token:, refresh_token:)
      Credential.new(access_token: access_token, refresh_token: refresh_token, credential_key: credential_key)
    end

    def exchange_refresh_token(refresh_token)
      new_token = oauth_client.get_token(grant_type: 'refresh_token', refresh_token: refresh_token)
      build_credential(access_token: new_token.token, refresh_token: new_token.refresh_token)
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
