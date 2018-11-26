defmodule LogLagerBackendTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  require Logger

  setup do
    console_config = Application.get_env(:logger, :console)

    :lager.set_loglevel(:lager_console_backend, :info)

    on_exit(fn ->
      Process.sleep(1000)
      Logger.remove_backend(LogLagerBackend)
      Logger.add_backend(:console, console_config)
    end)
  end

  def set_log_lager_backend(config \\ []) do
    Logger.remove_backend(:console)
    Logger.add_backend(LogLagerBackend)
    Logger.configure_backend(LogLagerBackend, config)
  end

  @tag :console_backend
  test "just log via :console" do
    msg = "Spare me the info"
    rgx = ~r/\e\[22m\n[\d:\.]+\s+\[info\]\s+Spare.me.the.info\n\e\[0m/

    log =
      capture_log(fn ->
        Logger.info(msg)
      end)

    assert Regex.match?(rgx, log)
  end

  test "log with metadata" do
    Logger.info(
      "log with metadata ------------------------------------------------------"
    )

    set_log_lager_backend(
      format: "$message - $metadata",
      metadata: [:module]
    )

    :lager.set_loglevel(:lager_console_backend, :debug)

    Logger.info("info")
    Logger.warn("warn")
    Logger.error("error")
    Logger.debug("debug")
  end

  test "otp reports should be not logged twice" do
    Logger.info(
      "Otp reports should be not logged twice. --------------------------------"
    )

    set_log_lager_backend(format: ">> $message <<")

    :error_logger.error_msg('The one and only!')
  end
end
