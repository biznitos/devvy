defmodule Devvy.Liquid.Utils do
  @moduledoc """
  Port of LiquidUtils from curator-web.
  Pure Liquid context helpers — no DB dependency.
  """

  @doc """
  Extract a value from parsed markup options.
  Markup is pre-split into a list of [key, value] pairs.
  """
  def extract_option(context, markup, key) do
    if n = Enum.find(markup, fn k -> List.first(k) == key end) do
      val = String.trim(List.last(n))

      cond do
        # Literal string value "foo"
        String.starts_with?(val, "\"") ->
          String.replace(val, "\"", "")
          |> String.trim()

        # Not literal value, so check in context
        v = get_liquid_value(context, val) ->
          v

        # Just return literal representation
        true ->
          val
      end
    else
      nil
    end
  end

  @doc """
  Grab a value from the Liquid context using dot notation.
  """
  def get_liquid_value(context, val) do
    v =
      Liquid.Variable.create(val)
      |> Liquid.Variable.lookup(context)
      |> elem(0)

    case v do
      "" -> nil
      "false" -> false
      nil -> nil
      _ -> v
    end
  end

  @doc """
  Parse tag markup into a list of [key, value] pairs.
  e.g. `type:"blog", limit:5, name:"articles"` → [["type", "\"blog\""], ["limit", "5"], ...]
  """
  def parse_markup(markup) do
    (markup || "")
    |> String.split(",")
    |> Enum.map(fn s -> String.trim(s) |> String.split(":") end)
  end

  @doc """
  Safe integer conversion.
  """
  def to_int(nil), do: nil
  def to_int(val) when is_integer(val), do: val

  def to_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error -> nil
    end
  end

  def to_int(_), do: nil
end
