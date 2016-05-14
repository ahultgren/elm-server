module Response exposing (..)


import Request


type alias Response =
  { id : Request.RequestId
  , body : String
  }
