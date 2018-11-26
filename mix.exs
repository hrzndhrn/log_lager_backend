defmodule LogLagerBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :log_lager_backend,
      version: "0.0.3",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:lager]
    ]
  end

  defp description() do
    "A logger backend that forwards log messages to lager."
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:lager, "~> 3.6"}
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hrzndhrn/log_lager_backend"}
    ]
  end
end
