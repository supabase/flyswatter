defmodule FlySwatter.Stack do
  @enforce_keys [:uri, :headers, :method]
  defstruct [:uri, :headers, :method]
  @type t :: %FlySwatter.Stack{uri: %URI{}, headers: [{String.t(), String.t()}], method: :atom}
end
