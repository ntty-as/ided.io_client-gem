require 'digest/md5'

module IdedClient
  class Credential
    attr_reader :access_token, :refresh_token

    def initialize(access_token:, refresh_token: nil, credential_key:)
      @access_token = access_token
      @refresh_token = refresh_token
      @credential_key = credential_key
    end

    def user_id
      token_payload.fetch("sub")
    end

    def user_name
      token_payload.fetch("user_name")
    end

    def user_email
      token_payload.fetch("user_email")
    end

    def user_gravatar
      hash = Digest::MD5.hexdigest(user_email.downcase)
      "https://www.gravatar.com/avatar/#{hash}"
    end

    def expired?
      jwt_token
      false
    rescue JWT::ExpiredSignature
      true
    end

    private

    attr_reader :credential_key

    def token_payload
      jwt_token.first
    end

    def jwt_token
      @jwt_token ||= JWT.decode access_token, credential_key, true, { algorithm: "RS512" }
    end
  end
end
