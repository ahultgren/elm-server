module Utils (..) where

import Types exposing (Request, Response)

createResponse : Request -> String -> Response
createResponse req body =
  { id = req.id
  , body = body
  }
