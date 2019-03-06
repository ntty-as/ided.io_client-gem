require "json_api_client"

module IdedClient
  class BaseResource < JsonApiClient::Resource
    def self.with_credential(cred, &block)
      with_headers(authorization: "Bearer #{cred.access_token}", &block)
    end

    def self.host=(host)
      self.site = "#{host}/api/v1"
    end

    # Set the default host for resources.
    self.host = "https://auth.ided.io"
  end
end
