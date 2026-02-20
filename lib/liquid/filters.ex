defmodule Devvy.Liquid.Filters do
  @moduledoc """
  Port of CuratorFilters from curator-web.
  All filters adapted for dev environment (placeholder images, no CDN, etc.)
  """

  def strip_html(nil), do: nil
  def strip_html(""), do: nil
  def strip_html(html) when is_binary(html), do: HtmlSanitizeEx.strip_tags(html)

  def proper(nil), do: nil
  def proper(str) when is_binary(str) do
    str
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
    |> String.trim()
  end

  def singular(nil), do: nil
  def singular(str) when is_binary(str) do
    # Simple singularize — handles common English patterns
    cond do
      String.ends_with?(str, "ies") -> String.replace_suffix(str, "ies", "y")
      String.ends_with?(str, "ves") -> String.replace_suffix(str, "ves", "f")
      String.ends_with?(str, "ses") -> String.replace_suffix(str, "ses", "s")
      String.ends_with?(str, "s") && !String.ends_with?(str, "ss") -> String.replace_suffix(str, "s", "")
      true -> str
    end
  end

  def to_url(nil), do: nil
  def to_url(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]+/u, "")
    |> String.replace(~r/[\s_-]+/, "_")
    |> String.trim("_")
  end

  # Money formatting
  def money(nil), do: nil
  def money(number) when is_binary(number) do
    number
    |> String.replace(~r/[^0-9\.]+/, "")
    |> format_currency()
  end
  def money(number), do: format_currency(number)

  def money(nil, _), do: nil
  def money(number, currency) when is_binary(number) do
    number
    |> String.replace(~r/[^0-9\.]+/, "")
    |> format_currency(currency)
  end
  def money(number, currency), do: format_currency(number, currency)

  defp format_currency(number, currency \\ "USD") do
    try do
      num = if is_binary(number), do: String.to_float(number), else: number / 1
      Number.Currency.number_to_currency(num, unit: currency_symbol(currency))
    rescue
      _ -> "#{number}"
    end
  end

  defp currency_symbol("THB"), do: "฿"
  defp currency_symbol("GBP"), do: "£"
  defp currency_symbol("EUR"), do: "€"
  defp currency_symbol("JPY"), do: "¥"
  defp currency_symbol("USD"), do: "$"
  defp currency_symbol(_), do: "$"

  # Prose formatting — wraps paragraphs with Tailwind prose styles
  def prose(nil), do: nil
  def prose(""), do: ""
  def prose(str) when is_binary(str) do
    "<div class=\"prose max-w-none\">#{str}</div>"
  end

  def prose_small(nil), do: nil
  def prose_small(""), do: ""
  def prose_small(str) when is_binary(str) do
    "<div class=\"prose prose-sm max-w-none\">#{str}</div>"
  end

  def tailwind_prose(nil), do: nil
  def tailwind_prose(""), do: ""
  def tailwind_prose(str) when is_binary(str) do
    "<div class=\"prose max-w-none\">#{str}</div>"
  end

  # Image resize — returns placeholder URL in dev
  def resize(url \\ nil, size \\ "100x100")
  def resize(nil, size), do: "https://placehold.co/#{size}"
  def resize("", size), do: "https://placehold.co/#{size}"
  def resize(url, size) do
    [w, h] = String.split(size, "x")
    "https://placehold.co/#{w}x#{h}?text=#{URI.encode(Path.basename(url))}"
  end

  # CDN passthrough in dev
  def to_cdn(url), do: url

  # Time ago in words
  def time_ago_in_words(nil), do: nil
  def time_ago_in_words(datetime) when is_binary(datetime) do
    case Timex.Parse.DateTime.Parser.parse(datetime, "{ISO:Extended:Z}") do
      {:ok, dt} -> Timex.from_now(dt)
      _ ->
        case Timex.Parse.DateTime.Parser.parse(datetime, "{ISO:Extended}") do
          {:ok, dt} -> Timex.from_now(dt)
          _ -> datetime
        end
    end
  end
  def time_ago_in_words(datetime), do: Timex.from_now(datetime)

  # Markdown
  def markdown(nil), do: nil
  def markdown(string) when is_binary(string) do
    case Earmark.as_html(string) do
      {:ok, html_doc, _} -> html_doc
      {:error, _, _} -> string
    end
  end
  def markdown(str), do: str

  # HTML encode/decode
  def html_encode(nil), do: nil
  def html_encode(string) when is_binary(string), do: HtmlEntities.encode(string)
  def html_encode(string), do: string

  def html_decode(nil), do: nil
  def html_decode(string) when is_binary(string), do: HtmlEntities.decode(string)
  def html_decode(string), do: string

  # JSON encode
  def json_encode(data) when is_map(data) do
    case Jason.encode(data) do
      {:ok, d} -> d
      _ -> "[data encode error]"
    end
  end
  def json_encode(_), do: "[data is not a map]"

  # Enum dynamic calls
  def enum(function, enumerable) do
    try do
      f = String.to_existing_atom(function)
      if Kernel.function_exported?(Enum, f, 1) do
        Kernel.apply(Enum, f, [enumerable])
      else
        enumerable
      end
    rescue
      ArgumentError -> enumerable
    end
  end

  def enum(function, enumerable, arg) do
    try do
      f = String.to_existing_atom(function)
      if Kernel.function_exported?(Enum, f, 2) do
        Kernel.apply(Enum, f, [enumerable, arg])
      else
        enumerable
      end
    rescue
      ArgumentError -> enumerable
    end
  end

  def enum(function, enumerable, arg1, arg2) do
    try do
      f = String.to_existing_atom(function)
      if Kernel.function_exported?(Enum, f, 3) do
        Kernel.apply(Enum, f, [enumerable, arg1, arg2])
      else
        enumerable
      end
    rescue
      ArgumentError -> enumerable
    end
  end

  # Domain extraction
  def domain(nil), do: nil
  def domain(""), do: nil
  def domain(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: nil} -> url
      %URI{host: host} -> host
    end
  end

  # Utils stub — no-op in dev
  def utils(_, _), do: nil
  def utils(_, _, _), do: nil
end
