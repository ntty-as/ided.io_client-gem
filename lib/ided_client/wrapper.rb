module IdedClient
  class Wrapper
    def auth
      @auth ||= IdedClient::Auth.new(
        ided_host: ided_host,
        redirect_uri: ENV.fetch("IDED_REDIRECT_URI"),
        client_id: ENV.fetch("IDED_CLIENT_ID"),
        client_secret: ENV.fetch("IDED_CLIENT_SECRET"),
        credential_key: credential_key,
      )
    end

    def credential_from_request(request)
      Credential.new(
        access_token: request.authorization.sub(/^Bearer /, ""),
        credential_key: credential_key,
      )
    end

    def setup
      # Ensure that auth env variables are present.
      auth

      IdedClient::BaseResource.host = ided_host
    end

    def ided_host
      @ided_host ||= ENV.fetch("IDED_HOST", "https://auth.ided.io")
    end

    private

    def credential_key
      OpenSSL::PKey::RSA.new(
        ENV.fetch("IDED_CREDENTIAL_KEY")
      )
    end
  end
end
