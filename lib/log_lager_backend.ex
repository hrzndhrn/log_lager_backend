defmodule LogLagerBackend do
  @moduledoc """
  A logger backend that forwards log messages to lager.
  """

  alias Logger.Formatter

  @behaviour :gen_event

  @size 4096
  @lager_format '~ts'

  defstruct level: nil,
            format: nil,
            metadata: nil

  def init(__MODULE__), do: init({__MODULE__, []})

  def init({__MODULE__, opts}) when is_list(opts) do
    config = Keyword.merge(Application.get_env(:logger, __MODULE__, []), opts)
    {:ok, init(config, %__MODULE__{})}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    %{level: log_level} = state

    if meet_level?(level, log_level), do: log_event(level, msg, ts, md, state)

    {:ok, state}
  end

  # No buffer, no flush.
  def handle_event(:flush, state), do: {:ok, state}

  def handle_event(_, state), do: {:ok, state}

  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  ## Helpers

  defp log_event(level, msg, ts, md, state) do
    msg = format_log(level, msg, ts, md, state)

    :lager.dispatch_log(
      :lager_event,
      lager_level(level),
      md,
      @lager_format,
      [msg],
      @size,
      :safe
    )
  end

  defp format_log(level, msg, ts, md, %{format: format, metadata: keys}) do
    Formatter.format(format, level, msg, ts, take_metadata(md, keys))
  end

  defp format_log(_level, msg, _ts, _md, %{format: nil}), do: msg

  defp lager_level(:warn), do: :warning

  defp lager_level(level), do: level

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
  end

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min), do: Logger.compare_levels(lvl, min) != :lt

  defp init(nil, state), do: init([], state)

  defp init(config, state) do
    level = Keyword.get(config, :level)
    format = Formatter.compile(Keyword.get(config, :format))
    metadata = Keyword.get(config, :metadata, [])

    %{
      state
      | format: format,
        metadata: metadata,
        level: level
    }
  end

  defp configure(options, state) do
    config = Keyword.merge(Application.get_env(:logger, __MODULE__, []), options)
    Application.put_env(:logger, __MODULE__, config)
    init(config, state)
  end
end
