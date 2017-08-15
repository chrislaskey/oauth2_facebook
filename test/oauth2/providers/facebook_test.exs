defmodule OAuth2.Provider.FacebookTest do

  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

  alias OAuth2.Client
  alias OAuth2.AccessToken
  alias OAuth2.Provider.Facebook

  setup do
    server = Bypass.open
    client = build_client(strategy: Facebook, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "client created with default values" do
    result = Facebook.client
    assert result.authorize_url == "https://www.facebook.com/dialog/oauth"
  end

  test "client takes optional values" do
    result = Facebook.client(authorize_url: "new")
    assert result.authorize_url == "new"
  end

  test "authorize_url!" do
    result = Facebook.authorize_url!([], [])
    assert Regex.match?(~r/facebook.com/, result)
  end

  test "authorize_url", %{client: client, server: server} do
    client = Facebook.authorize_url(client, [])
    assert "http://localhost:#{server.port}" == client.site

    assert client.params["client_id"] == client.client_id
    assert client.params["redirect_uri"] == client.redirect_uri
    assert client.params["response_type"] == "code"
  end

  test "get_token", %{client: client, server: server} do
    code = "abc1234"
    access_token = "access-token-1234"

    Bypass.expect server, fn conn ->
      assert conn.request_path == "/oauth/token"
      assert get_req_header(conn, "content-type") == ["application/x-www-form-urlencoded"]
      assert conn.method == "POST"

      {:ok, body, conn} = read_body(conn)
      body = URI.decode_query(body)

      assert body["grant_type"] == "authorization_code"
      assert body["code"] == code
      assert body["client_id"] == client.client_id
      assert body["redirect_uri"] == client.redirect_uri

      send_resp(conn, 200, ~s({"access_token":"#{access_token}"}))
    end

    assert {:ok, %Client{token: token}} = Client.get_token(client, [code: code])
    assert token.access_token == access_token
  end

  test "get_token throws and error if there is no 'code' param" do
    assert_raise OAuth2.Error, ~r/Missing required key/, fn ->
      Facebook.get_token(build_client(), [], [])
    end
  end

  test "user_path", %{client: client} do
    access_token = %AccessToken{access_token: "test-token"}
    client = Map.put(client, :token, access_token)

    result = Facebook.user_path(client)
    expected = "/me?appsecret_proof=4b7ac26ded30aa0308ad850fd10ebf251676997fd03a1700748b03beb23ada32&fields=id%2Cemail%2Cgender%2Clink%2Clocale%2Cname%2Cfirst_name%2Clast_name%2Ctimezone%2Cupdated_time%2Cverified"

    assert result == expected
  end

  test "user_path takes custom params", %{client: client} do
    access_token = %AccessToken{access_token: "test-token"}
    client = Map.put(client, :token, access_token)
    custom_params = [
      appsecret_proof: nil,
      fields: "email"
    ]

    result = Facebook.user_path(client, custom_params)
    expected = "/me?fields=email"

    assert result == expected
  end

  test "appsecret_proof" do
    result = Facebook.appsecret_proof("test-value")
    expected = "124ed8be8bca56fc1cbf60c697077713ea893375edb8c825529522c8c336a4a6"

    assert result == expected
  end
end
