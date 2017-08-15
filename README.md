# OAuth2 Facebook

> A Facebook OAuth2 Provider for Elixir

[![Build Status](https://travis-ci.org/chrislaskey/oauth2_facebook.svg?branch=master)](https://travis-ci.org/chrislaskey/oauth2_facebook)
[![Coverage Status](https://coveralls.io/repos/github/chrislaskey/oauth2_facebook/badge.svg?branch=master)](https://coveralls.io/github/chrislaskey/oauth2_facebook?branch=master)

OAuth2 Facebook is convenience library built on top of [`oauth2`](https://hex.pm/packages/oauth2). It adds Facebook specific functions to interact with the Facebook Graph endpoints using OAuth2.

## Installation

```elixir
# mix.exs

def application do
  # Add the application to your list of applications.
  # This will ensure that it will be included in a release.
  [applications: [:logger, :oauth2_facebook]]
end

defp deps do
  # Add the dependency
  [{:oauth2_facebook, "~> 0.1"}]
end
```

## Authenticating a User

> For an easy-to-use, end-to-end solution enabling users to log in with Facebook see [`ueberauth/ueberauth_facebook`](https://github.com/ueberauth/ueberauth_facebook)

One common use-case is authenticating a user's identify. The `get_user!` function wraps two actions into one - exchanging the callback code for a short-lived access token and using the access token to return user data:

```elixir
alias OAuth2.Provider.Facebook

Facebook.get_user!([code: "<callback-code>"], [redirect_uri: "..."])
```

When successful, it returns the user data:

```elixir
{:ok, %{"email" => "user@gmail.com", "gender" => "male", "id" => "101", "link" => "https://www.facebook.com/app_scoped_user_id/101/", "locale" => "en_US", "name" => "user", "timezone" => -4, "updated_time" => "2015-06-05T14:59:20+0000", "verified" => true}}
```

## Returning an Access Token

A valid access token can be used to make multiple requests to the Facebook Graph. The callback code can be exchanged for an access token using `get_token!`:

```elixir
alias OAuth2.Provider.Facebook

client = Facebook.get_token!([code: "<callback-code>"], [redirect_uri: "..."])
```

When successful, it will return a valid `OAuth2.Client`:

```
%OAuth2.Client{authorize_url: "https://www.facebook.com/dialog/oauth", client_id: "<...>", client_secret: "<...>", headers: [], params: %{}, redirect_uri: "http://localhost:3000/login/facebook/callback", ref: nil, request_opts: [], site: "https://graph.facebook.com", strategy: OAuth2.Provider.Facebook, token: %OAuth2.AccessToken{access_token: "EAABw0PjpdjcBAMDUjWQtZApFV2nFJfhIUWaw3z8MSbi92fVooa2BNBdZBeRaxMcHO94zdmncoFuZBvQQdj0cmXosa8kAZCx7wtlSR5ByT2etOhURZCNjs9DDFfpU456Gk8f0tvzmtYsiMstSKkh69kIzSVOeQIx8TPQOLpXHnRCARNXCiiB1Y", expires_at: 1507926168, other_params: %{}, refresh_token: nil, token_type: "Bearer"}, token_method: :get, token_url: "/v2.8/oauth/access_token"}
```

**Note:** The access token is kept under the client's `token` key.

## Using a Valid Client

A valid client with an access token can then be passed into endpoint specific functions. For example, to return user data using a `client` with a valid access token:

```elixir
alias OAuth2.Provider.Facebook

{:ok, user} = Facebook.get_user(client)
```

When successful, it will return the same user information:

```elixir
%{"email" => "user@gmail.com", "gender" => "male", "id" => "101", "link" => "https://www.facebook.com/app_scoped_user_id/101/", "locale" => "en_US", "name" => "user", "timezone" => -4, "updated_time" => "2015-06-05T14:59:20+0000", "verified" => true}
```

## Filtering User fields

Both `get_user!` and `get_user` support passing custom query params. These can be used to filter the returned attributes:

```elixir
alias OAuth2.Provider.Facebook

# Using `get_user!`
user = Facebook.get_user!([code: "<callback-code>"], [redirect_uri: "..."], [fields: "email,name"])

# Using `get_user`
client = Facebook.get_token!([code: "<callback-code>"], [redirect_uri: "..."])
{:ok, user} = Facebook.get_user(client, [fields: "email,name"])
```

When successful, will return a trimmed down user:

```elixir
%{"email" => "user@gmail.com", "id" => "101", "name" => "user"}
```

**Note:** The `id` value is always returned.
