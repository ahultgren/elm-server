module Http
  exposing ( Error(..), Request, Response
  )

-- Borrowed from https://github.com/ElmCast/elm-node/blob/master/src/Http.elm

{-|

@docs Error
@docs get, serve, getURL, sendResponse

-}

import Task exposing (Task)

-- import Native.Http

{-| Error
-}
type Error = NetworkError String


{-| Request
-}
type Request = Request


{-| Response
-}
type Response = Response
