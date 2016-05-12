module Http
  exposing ( Error(..), get
  )

-- Borrowed from https://github.com/ElmCast/elm-node/blob/master/src/Http.elm

{-|

@docs Error

-}

import Task exposing (Task)

import Native.Http

{-| Error
-}
type Error = NetworkError String

{-| get
-}
get : String -> Task Error String
get url =
  Native.Http.get url
