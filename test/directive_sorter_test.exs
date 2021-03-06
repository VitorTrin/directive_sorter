defmodule DirectiveSorterTest do
  use ExUnit.Case

  describe "format_string!/1" do
    setup do
      simple_wrong_file = """
      defmodule Foo do
        alias A.B
        alias A.D
        alias A.C

        def hello(), do: :ok
      end
      """

      simple_right_file = """
      defmodule Foo do
        alias A.B
        alias A.C
        alias A.D

        def hello(), do: :ok
      end
      """

      %{simple_right_file: simple_right_file, simple_wrong_file: simple_wrong_file}
    end

    test "should reorder lines when the order of imports is wrong", %{
      simple_right_file: simple_right_file,
      simple_wrong_file: simple_wrong_file
    } do
      assert simple_right_file == DirectiveSorter.format_string!(simple_wrong_file)
    end

    test "should not change strings that are right", %{simple_right_file: simple_right_file} do
      assert simple_right_file == DirectiveSorter.format_string!(simple_right_file)
    end

    test "should delete spaces in ordered strings", %{simple_right_file: simple_right_file} do
      spaced_file = """
      defmodule Foo do
        alias A.B
        alias A.D

        alias A.C

        def hello(), do: :ok
      end
      """

      assert simple_right_file == DirectiveSorter.format_string!(spaced_file)
    end

    test "should delete spaces in unordered strings", %{simple_right_file: simple_right_file} do
      spaced_unsorted_file = """
      defmodule Foo do
        alias A.D
        alias A.B

        alias A.C

        def hello(), do: :ok
      end
      """

      assert simple_right_file == DirectiveSorter.format_string!(spaced_unsorted_file)
    end
  end
end
