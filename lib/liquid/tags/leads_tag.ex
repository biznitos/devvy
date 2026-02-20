defmodule Devvy.Liquid.Tags.LeadsTag do
  @moduledoc """
  Port of CuratorLeadsTag — filters in-memory leads list.
  Usage: {% leads type:"contact", limit:5 %}
  """
  import Devvy.Liquid.Utils

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    markup = parse_markup(tag.markup)

    limit = to_int(extract_option(context, markup, "limit") || "10") || 10
    type = extract_option(context, markup, "type")
    subtype = extract_option(context, markup, "subtype")
    status = extract_option(context, markup, "status")
    zid = extract_option(context, markup, "zid")
    one = extract_option(context, markup, "one") || false

    all_leads = get_liquid_value(context, "all_leads") || []

    leads = all_leads

    leads = if type, do: Enum.filter(leads, fn l -> l["type"] == type end), else: leads
    leads = if subtype, do: Enum.filter(leads, fn l -> l["subtype"] == subtype end), else: leads
    leads = if status, do: Enum.filter(leads, fn l -> l["status"] == status end), else: leads
    leads = if zid, do: Enum.filter(leads, fn l -> l["zid"] == zid end), else: leads

    leads = Enum.take(leads, limit)

    out =
      if one && length(leads) > 0 do
        List.first(leads)
      else
        leads
      end

    assigns = Map.put(context.assigns, "leads", out)
    context = Map.put(context, :assigns, assigns)

    txt_out = "<!-- leads: #{if is_list(out), do: length(out), else: 1} -->"
    {[txt_out] ++ output, context}
  end
end
