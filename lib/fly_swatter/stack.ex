defmodule FlySwatter.Stack do
  @enforce_keys [:uri, :headers, :method]
  defstruct uri: "", headers: [], method: :get, parser: :json, every: 60_000, regions: [:all]

  @type t :: %FlySwatter.Stack{
          uri: %URI{},
          headers: [{String.t(), String.t()}],
          method: :atom,
          parser: :atom,
          every: non_neg_integer(),
          regions: [:atom]
        }
end
