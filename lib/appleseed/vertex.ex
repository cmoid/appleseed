defmodule Appleseed.Vertex do
  @moduledoc """
  """

  defstruct name: "", energy: 0, trust: 0

  alias __MODULE__, as: V

  def create(name) do
    {:ok, %V{name: name}}
  end
end
