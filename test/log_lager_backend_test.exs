defmodule LogLagerBackendTest do
  use ExUnit.Case

  require Logger

  test "greets the world" do
    Logger.remove_backend(:console)
    Logger.add_backend LogLagerBackend
    Logger.configure_backend(
      LogLagerBackend,
      format: "$message - $metadata\n",
      metadata: [:module]
    )

    :lager.set_loglevel(:lager_console_backend, :debug)
    Logger.info("info")
    Logger.warn("warn")
    Logger.error("error")
    Logger.debug("debug")
    Process.sleep(100)
  end
end
