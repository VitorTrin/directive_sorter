defmodule AliasSorterTest do
  use ExUnit.Case

  describe "sort_string!/1" do
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
      assert simple_right_file == AliasSorter.sort_string!(simple_wrong_file)
    end

    test "should not change strings that are right", %{simple_right_file: simple_right_file} do
      assert simple_right_file == AliasSorter.sort_string!(simple_right_file)
    end
  end
end
