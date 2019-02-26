module IdedClient
  module TestHelpers
    class << self
      def user_test_token(id = SecureRandom.uuid, exp = 7200)
        payload = {
          sub: id,
          user_email: "test@example.com",
          user_name: "Bob McTester",
          exp: Time.now.utc.to_i + exp,
        }
        JWT.encode(payload, private_key, "RS512")
      end

      def public_key
        private_key.public_key
      end

      private

      def private_key
        @private_key ||= OpenSSL::PKey::RSA.generate 2048
      end
    end
  end
end
