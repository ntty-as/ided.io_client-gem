require "ided_client/auth"
require "ided_client/base_resource"
require "ided_client/credential"
require "ided_client/team"
require "ided_client/organisation"
require "ided_client/version"
require "ided_client/wrapper"

module IdedClient
  def self.build
    Wrapper.new
  end
end
