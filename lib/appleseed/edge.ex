defmodule Appleseed.Edge do
  @moduledoc """
  """

  defstruct [:src, :tar, weight: 0]

  alias __MODULE__, as: E

  def create(src, tar, weight) do
    {:ok, %E{src: src, tar: tar, weight: weight}}
  end
end
