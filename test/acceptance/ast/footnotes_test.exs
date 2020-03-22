defmodule Acceptance.Ast.FootnotesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2, parse_html: 1]


  describe "Footnotes without errors" do
    test "debugging" do
      markdown = """
                 foo[^1] alpha

                 - bar[^2] beta

                 goo[^3] gamma

                 [^1]: A

                 [^2]: A

                 [^3]: A

                 [^4]: A
                 """
      as_ast(markdown, footnotes: true)
    end
    test "simple case" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"
      # TODO: Check if we should put a `<sup>` around `<a></a>`
      ast      = [
        {"p", '', ["foo", {"a", [{"href", "#fn:1"}, {"id", "fnref:1"}, {"class", "footnote"}, {"title", "see footnote"}], ["1"]}, " again"]},
        {
          "div",
          [{"class", "footnotes"}],
          [
            {"hr", '', ''},
            {
              "ol",
              '',
              [
                {
                  "li",
                  [{"id", "fn:1"}],
                  [
                    {
                      "p",
                      '',
                      ["bar baz", {"a", [{"class", "reversefootnote"}, {"href", "#fnref:1"}, {"title", "return to article"}], ["&#x21A9;"]}]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
      messages = []

      assert as_ast(markdown, footnotes: true) == {:ok, ast, messages}
    end

    test "simple case w/o footnotes" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"
      ast      = [ {"p", '', ["foo[^1] again"]}, {"p", [], ["[^1]: bar baz"]} ]
      messages = []

      assert as_ast(markdown, footnotes: false) == {:ok, ast, messages}
    end

    test "inside a list item" do
      markdown = """
                 1. foo[^1]
                  
                 [^1]: bar baz
                 """ |> IO.inspect
      html = ~s{<ol>\n  <li>\n    foo[^1]\n  </li>\n</ol>\n<p>\n  [^1]: bar baz\n</p>\n}
      ast  = parse_html(html)
      messages = []

      assert as_ast(markdown, footnotes: true) == {:ok, ast, messages}
    end

    test "inside a link" do
    end
  end

  describe "error cases" do

    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      html     = ~s{<p>foo[^1]\nhello</p>\n}
      ast      = parse_html(html)
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      html     = ~s{<p>foo[^1]\nhello</p>\n}
      ast      = parse_html(html)
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      html     = ~s{<p>foo[^1]\nhello</p>\n<p>[^1]:bar baz</p>\n}
      ast      = parse_html(html)
      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}]

       assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end
  end


end

# SPDX-License-Identifier: Apache-2.0
