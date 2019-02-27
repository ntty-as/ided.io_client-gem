# IdedClient

This gem is a wrapper around ided.io that makes it easier to interact with. It aims to:
- Simplify generating URLs to get auth tokens.
- Help with using the API to access information such as teams and organisations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ided_client', github: 'elmatica/ided_client-gem'
```

And then execute:

    $ bundle

## Usage

Add an initializer:

```ruby
IDED_CLIENT = IdedClient.build

IDED_CLIENT.setup unless Rails.env.test?
```

Calling the `setup` method assumes that you have the following environment variables available (some example values shown):
```
IDED_HOST=https://auth.ided.io
IDED_REDIRECT_URI=https://myapp.localhost/oauth-redirect
IDED_CLIENT_ID=something-from-ided
IDED_CLIENT_SECRET=secret-from-ided
IDED_CREDENTIAL_KEY=something-else-from-ided
```

You can add these to the file `.env.development` and use [dotenv-rails](https://github.com/bkeepers/dotenv) to load it if you are using rails.

### Generating a login link
To generate a link for logging in use:
```ruby
IDED_CLIENT.auth.authorize_url
```

### Getting a token
The final step of authenticating a user is when they comeback to your application with a `code`. This needs to be exchanged for a token before you can access the API and determine who they are.

Setup a handler for the route `https://myapp.localhost/oauth-redirect` in your application. In rails this looks something like:
```ruby
class OauthRedirectController < ApplicationController
  def index
    cred = IDED_CLIENT.client.exchange_code_for_credential(params[:code])
    session[:access_token] = cred.access_token

    redirect_to("/your-home-page-goes-here")
  end
end
```

### Using the token

To make use of the token in your session you can utilize the following helpers for your controller:
```ruby
def access_token
  session[:access_token]
end

def authenticated_as_user?
  access_token.present? && user_id.present?
end

def credential
  @credential ||= IDED_CLIENT.auth.build_credential(access_token: access_token)
end

def user_id
  credential.user_id
end

def current_user
  @current_user ||= User.find_or_create_by!(id: id) do |user|
    user.name = credential.user_name

    hash = Digest::MD5.hexdigest(credential.user_email)
    user.photo_url = "https://www.gravatar.com/avatar/#{hash}"
  end
end
```

Add a before filter to protect the routes you would like to:
```ruby
before_action :ensure_user_present

def ensure_user_present
  unless current_user.present?
    redirect_to '/login'
  end
end
```

### Handling tokens expiring
A token is valid for a defined period (approx 2 hours currently). After this the token is no longer valid.

To handle this case you can add something like the following to your controller:
```ruby
rescue_from JWT::ExpiredSignature do
  reset_session

  # For an API you could respond with:
  render plain: {errors: [{ code: "session-expired" }]}.as_json,
    content_type: "application/json",
    status: 401
  # Or for a normal site:
  redirect_to '/login'
end
```

### Accessing the APIs

To access the API as the user who has logged in use the credential object. For example:

```ruby
def team_ids
  IdedClient::Team.with_credential(credential) do
    IdedClient::Team.select(:id).all.pluck(:id)
  end
end
```

### Linking to ided.io

If you want to have a link to ided.io then you can use `IDED_CLIENT.ided_host` to generate the base of the link.


### Testing

To help testing your system without testing the behaviour of ided.io you can mock ided.io with some test helpers.

With the helpers below you can call `login` before your `request` or `system` specs and the user should be logged in without needing ided.io.

```ruby
require "ided_client/test_helpers"

module UserHelpers
  def login(user: test_user, team_id: default_team_id, exp: 7200)
    token = IdedClient::TestHelpers.user_test_token(test_user.id, exp)
    setup_session(token)

    stub_api(token, team_id)
  end

  def test_user
    @test_user ||= create(:user)
  end

  def default_team_id
    "14aa11ba-6e15-4360-8bfc-d50c1265c5e3"
  end

  def setup_session(token)
    is_set = false
    allow_any_instance_of(ApplicationController).to receive(:access_token) do |cntrl|
      unless is_set
        cntrl.session[:access_token] = token
        is_set = true
      end
      cntrl.session[:access_token]
    end
  end

  def stub_api(token, team_id)
    # If you are using Webmock to stub external services:
    stub_request(:get, "http://test-ided.localhost/api/v1/teams?fields%5Bteams%5D=id")
      .with(headers: { "Authorization" => "Bearer #{token}" })
      .to_return(
        status: 200,
        body: %Q({"data":[{"id": "#{team_id}"}]}),
        headers: { 'Content-Type': "application/vnd.api+json" },
      )
  end
end

RSpec.configure do |config|
  config.include UserHelpers

  def setup_ided_client
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("IDED_HOST").and_return("http://test-ided.localhost")
    allow(ENV).to receive(:fetch).with("IDED_REDIRECT_URI").and_return("http://test-ided.localhost/redirect")
    allow(ENV).to receive(:fetch).with("IDED_CLIENT_ID").and_return("pizza-client-yo")
    allow(ENV).to receive(:fetch).with("IDED_CLIENT_SECRET").and_return("super-secret-calzone")
    allow(ENV).to receive(:fetch).with("IDED_CREDENTIAL_KEY").and_return(IdedClient::TestHelpers.public_key.to_s)
    CdpIded.setup_resources
  end

  config.before(:each, type: :request) { setup_ided_client }
  config.before(:each, type: :system) { setup_ided_client }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elmatica/ided_client.
