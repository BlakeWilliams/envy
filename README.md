# Envy

A simple Elixir library to load environment variables from `.env` and
environment specific env files like `.env.dev`, `.env.test`, etc.

## Installation

Add envy to your dependencies in `mix.exs`.

```elixir
def deps do
  [{:envy, "~> 1.1.1"}]
end
```

## Usage

To load env files you have two options, you can use the autoloader or give the
library paths to specific files to load itself.

Using `auto_load` you can add the following to your application in `lib/my_application.ex`:

```elixir
defmodule MyApplication do
  use Application

  def start(_type, _args) do
    unless Mix.env == :prod do
      Envy.auto_load
    end
    # Existing code
  end
end
```

This will look for `.env` and the mix env specific file. For example if your
applications `Mix.env` is `dev` then envy will attempt to load `.env.dev`

You can also specify which files to load manually using `Envy.load` which
accepts a list of files to attempt to load.

```elixir
Envy.load([".env"])
```

To export `FOO` as `bar` you can add the following line to your env file.

```
foo=bar
```

Comments can be added with a `#`.

```
foo=bar # comments
```

If you need to use `#` in your values you can use double quotes.

```
tag="#bar" #comments
```

## Using Envy in config

If you need environment variables set by envy in `config/` files you can load
your env files with `Envy.auto_load` or `Envy.load` then call
`Envy.reload_config` to re-evaluate the config files with the correct
environment variables set.
