defmodule Envy do
  @key_value_delimeter "="

  @moduledoc """
  Provides explicit and auto loading of env files.

  ## Example

  The following will set the `FOO` environment variable with the value of `bar`.

  ```
  foo=bar
  ```

  You can define comments with `#` but can't use `#` in values without wrapping
  the value in double quotes.

  ```
  foo="#bar" # Comment
  ```
  """

  @doc """
  Loads the `.env` and the `Mix.env` specific env file.

  eg: If `Mix.env` is `test` then envy will attempt to load `.env.test`.
  """
  def auto_load do
    Application.ensure_started(:mix)
    current_env = Mix.env |> to_string |> String.downcase

    [".env", ".env.#{current_env}"] |> load
  end

  @doc """
  Loads a list of env files.
  """
  def load(env_files) do
    for path <- env_files do
      if File.exists?(path) do
        File.read!(path) |> parse
      end
    end
  end

  @doc """
  Reloads `config/config.exs`. This function can be used to reload configuration
  that relies on environment variables set by Envy.

  This workaround is necessary since config files don't have
  access to dependencies.
  """
  def reload_config do
    Mix.Config.read!("config/config.exs") |> Mix.Config.persist
  end

  @doc """
  Parses env formatted file.
  """
  def parse(content) do
    content |> get_pairs |> load_env
  end

  defp get_pairs(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&blank_entry?/1)
    |> Enum.reject(&comment_entry?/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [key, value] = line
      |> String.strip
      |> String.split(@key_value_delimeter, parts: 2)

    [key, parse_value(value)]
  end

  defp parse_value(value) do
    if String.starts_with?(value, "\"") do
      unquote_string(value)
    else
      value |> String.split("#", parts: 2) |> List.first
    end
  end

  defp unquote_string(value) do
    value
    |> String.split(~r{(?<!\\)"}, parts: 3)
    |> Enum.drop(1)
    |> List.first
    |> String.replace(~r{\\"}, ~S("))
  end

  defp load_env(pairs) when is_list(pairs) do
    Enum.each(pairs, fn([key, value]) ->
      System.put_env(String.upcase(key), value)
    end)
  end

  defp blank_entry?(string) do
    string == ""
  end

  defp comment_entry?(string) do
    String.match?(string, ~r(^\s*#))
  end
end
