module Server (..) where

import Signal

port incoming : Signal (String, Int)

port outgoing : Signal (String, Int)
port outgoing = Signal.map addOne incoming

addOne : (String, Int) -> (String, Int)
addOne (id, x) =
  (id, x + 1)
