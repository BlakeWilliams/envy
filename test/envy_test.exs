defmodule EnvyTest do
  use ExUnit.Case

  test "parses and puts dotenv config in the system environment" do
    Envy.parse("foo=bar\nbar=foo")

    assert System.get_env("FOO") == "bar"
    assert System.get_env("BAR") == "foo"
  end

  test "parse can handle quotes with comments" do
    Envy.parse(~s(foo="bar#" # comment))

    assert System.get_env("FOO") == "bar#"

    cleanup_env(["FOO"])
  end

  test "parse handle escaped quotes" do
    Envy.parse(~S(foo="\"awesome\""))

    assert System.get_env("FOO") == ~S("awesome")

    cleanup_env(["FOO"])
  end

  test "it can parse .env in the current directory" do
    run_in_dir("test-env", fn ->
      File.write(".env", "elixir=awesome", [:write])
      Envy.auto_load

      assert System.get_env("ELIXIR") == "awesome"

      cleanup_env(["ELIXIR"])
    end)
  end

  test "it can parse environment specific .env files with precedence" do
    run_in_dir("test-env", fn ->
      Mix.env(:test)
      File.write(".env", "elixir=awesome", [:write])
      File.write(".env.test", "elixir=amazing\nruby=great too", [:write])

      Envy.auto_load

      assert System.get_env("ELIXIR") == "amazing"
      assert System.get_env("RUBY") == "great too"

      cleanup_env(["ELIXIR", "RUBY"])
    end)
  end

  test "it can load any given path to env" do
    run_in_dir('test-dir', fn ->
      File.write(".fakeenv", "elixir=awesome", [:write])
      Envy.load([".fakeenv"])

      assert System.get_env("ELIXIR") == "awesome"

      cleanup_env(["ELIXIR"])
    end)
  end

  defp run_in_dir(dir, func) do
    original_env = System.get_env |> Map.keys
    original_directory = File.cwd!
    File.mkdir(dir)
    File.cd!(dir)

    func.()

    File.cd!(original_directory)
    File.rm_rf(dir)

    new_env = System.get_env |> Map.keys
    Enum.each(original_env -- new_env, &cleanup_env/1)
  end

  defp cleanup_env(keys) do
    Enum.each(keys, fn(key) ->
      System.delete_env(key)
    end)
  end
end
