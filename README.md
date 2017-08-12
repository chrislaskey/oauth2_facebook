# OAuth2 Facebook

> A Facebook OAuth2 Provider for Elixir

[![Build Status](https://travis-ci.org/chrislaskey/oauth2_facebook.svg?branch=master)](https://travis-ci.org/chrislaskey/oauth2_facebook)

## Install

```elixir
# mix.exs

def application do
  # Add the application to your list of applications.
  # This will ensure that it will be included in a release.
  [applications: [:logger, :oauth2, :oauth2_facebook]]
end

defp deps do
  # Add the dependency
  [{:oauth2, "~> 0.9"},
   {:oauth2_facebook, "~> 0.1"}]
end
```

## Usage

Capture the `code` in your callback route on your server and use it to obtain an access token.

```elixir
client = OAuth2.Provider.Facebook.get_token!([code: "..."], [redirect_uri: "..."])
```
