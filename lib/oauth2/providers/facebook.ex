defmodule OAuth2.Provider.Facebook do
  @moduledoc """
  OAuth2 Facebook Provider

  Based on github.com/ueberauth/ueberauth_facebook

  Add `client_id` and `client_secret` to your configuration:

      config :oauth2, OAuth2.Strategy.Facebook,
        client_id: System.get_env("FACEBOOK_APP_ID"),
        client_secret: System.get_env("FACEBOOK_APP_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://graph.facebook.com",
    authorize_url: "https://www.facebook.com/dialog/oauth",
    token_url: "/v2.8/oauth/access_token",
    token_method: :get
  ]

  @doc """
  Construct a client for requests to Facebook.
  This will be setup automatically for you in `Ueberauth.Strategy.Facebook`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    opts =
      @defaults
      |> Keyword.merge(config())
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Returns an OAuth2.Client with token.
  """
  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  @doc """
  Returns user information only.
  To return token before querying for user, see `get_user/3`
  """
  def get_user!(params \\ [], opts \\ [], query_params \\ []) do
    OAuth2.Provider.Facebook.get_token!(params, opts)
    |> get_user(query_params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  @doc """
  Returns user information from Facebook graph's `/me` endpoint using the access_token.
  """
  def get_user(client, query_params \\ []) do
    case OAuth2.Client.get(client, user_path(client query_params)) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        {:error, "Unauthorized"}
      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
        when status_code in 200..399 ->
        {:ok, user}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # Helpers

  def user_path(client, query_params \\ []) do
    "/me?" <> user_query(client.token.access_token, query_params)
  end

  defp user_query(access_token, query_params) do
    Enum.into(query_params, %{})
    |> Map.put("fields", query_value(:user_fields))
    |> Map.put("appsecret_proof", appsecret_proof(access_token))
    |> URI.encode_query
  end

  defp query_value(:user_fields) do
    "id,email,gender,link,locale,name,timezone,updated_time,verified"
  end

  def appsecret_proof(access_token) do
    access_token
    |> hmac(:sha256, get_config(:client_secret))
    |> Base.encode16(case: :lower)
  end

  defp config do
    Application.get_env(:oauth2_facebook, OAuth2.Provider.Facebook)
  end 

  defp get_config(key) do
    Keyword.get(config(), key)
  end 

  defp hmac(data, type, key) do
    :crypto.hmac(type, key, data)
  end
end
