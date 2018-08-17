defmodule Skitter.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Skitter"
    ]
  end

  defp deps do
    [
      # Dev tools
      {:distillery, "~> 2.0", runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
