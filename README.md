# MastodonLocalTimeline

This is just an experiment to display Mastodon local timeline on the terminal.

# Prerequisites

* Mastodon account (on any instance)
* Access token

# How to run

Copy `config/dev.secret.exs.sample` to `config/dev.secret.exs` and fix its contents.
It would be something like this:

```elixir
use Mix.Config

config :mastodon_local_timeline,
  host: "Hostname for your instance",
  access_token: "your access token"
```

Run `iex -S mix` and,

```elixir
MastodonLocalTimeline.start
```
