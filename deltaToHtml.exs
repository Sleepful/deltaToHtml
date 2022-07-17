defmodule HTML do
  def htmlList(type) do
    case type do
      "ordered" -> "ol"
      "bullet" -> "ul"
    end
  end

  def tag(t) do
    "<" <> t <> ">"
  end

  def untag(t) do
    "</" <> t <> ">"
  end

  def li(txt) do
    "<li>" <> txt <> "</li>"
  end

  def go(json, last) do
    [current | rest] = json
    %{type: _, indent: indent, text: text} = current

    case rest do
      [next | _] ->
        %{indent: n_indent, type: n_type} = next

        case indent do
          _ when n_indent > indent ->
            opening = tag("li") <> text <> tag(htmlList(n_type))
            closing = untag(htmlList(n_type)) <> untag("li")
            opening <> go(rest, [closing | last])

          _ when n_indent < indent ->
            n = indent - n_indent
            {closing, notyet} = Enum.split(last, n)
            li(text) <> List.to_string(closing) <> go(rest, notyet)

          _ when indent == n_indent ->
            li(text) <> go(rest, last)
        end

      # last json row
      [] ->
        li(text) <> hd(last)
    end
  end

  def deltaToHtml(input) do
    %{type: firstType} = List.first(input)
    begin = HTML.tag(HTML.htmlList(firstType))
    ending = HTML.untag(HTML.htmlList(firstType))

    IO.puts(
      begin <>
        HTML.go(input, [ending])
    )
  end
end

input = [
  %{text: "One", indent: 0, type: "ordered"},
  %{text: "Two", indent: 0, type: "ordered"},
  %{text: "Alpha", indent: 1, type: "bullet"},
  %{text: "Beta", indent: 1, type: "bullet"},
  %{text: "I", indent: 2, type: "ordered"},
  %{text: "II", indent: 2, type: "ordered"},
  %{text: "Three", indent: 0, type: "ordered"}
]

HTML.deltaToHtml(input)
