defmodule OAuth2Facebook.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :oauth2_facebook,
     name: "OAuth2 Facebook",
     version: @version,
     elixir: "~> 1.3",
     deps: deps(),
     package: package(),
     description: description(),
     docs: docs(),
     elixirc_paths: elixirc_paths(Mix.env),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "docs": :dev
     ]]
  end

  def application do
    [applications: [:logger, :hackney, :oauth2],
     env: [serializers: %{"application/json" => Poison}]]
  end

  defp deps do
    [{:oauth2, "~> 0.9"},

     # Test dependencies
     {:poison, "~> 3.1", only: :test},
     {:bypass, "~> 0.6", only: :test},
     {:excoveralls, "~> 0.7", only: :test},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},

     # Docs dependencies
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    "A Facebook OAuth2 Provider for Elixir"
  end

  defp docs do
    [extras: ["README.md"],
     main: "readme",
     source_ref: "v#{@version}",
     source_url: "https://github.com/chrislaskey/oauth2_facebook"]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Chris Laskey"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/chrislaskey/oauth2_facebook"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
