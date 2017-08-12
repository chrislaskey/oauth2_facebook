use Mix.Config

config :logger, level: :info

config :oauth2_facebook, OAuth2.Provider.Facebook,
  client_id: "example-id",
  client_secret: "example-secret",
  redirect_uri: "http://example.dev"
