# LogLagerBackend

A [Logger](https://hexdocs.pm/logger/Logger.html) backend that forwards log
messages to [lager](https://github.com/erlang-lager/lager).

LogLagerBackend is in early beta. If you try it and has an issue, report them.

## Installation
First, add LogLagerBackend to your mix.exs dependencies:

```
def deps do
  [{:xema, "~> 0.0.1"}]
end
```

Then, update your dependencies:

```
$ mix deps.get
```

## Configuration

Setup a configuration in `config/config.exs`.

```
config :logger,
  backends: [LogLagerBackend],
  handle_otp_reports: false

config :logger, LogLagerBackend,
  level: :info,
  format: "$metadata - $message",
  metadata: [:module]
```

The options `level`, `format` and `metadata` will be treated like by the
`:console` backend. If a message has the right level it will be formatted and
forwarded to `lager`. All options for `lager` have an impact on our forwarded
message.

## Runtime Configuration

The backend can also be configured at runtime.

```
Logger.add_backend(LogLagerBackend)
Logger.configure_backend(
  LogLagerBackend,
  format: "$message - $metadata",
  metadata: [
    :client_id,
  ],
  level: :warn
)

# and if you don't want the :console backend
Logger.remove_backend(:console)
```

