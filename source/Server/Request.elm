module Request exposing (..)


import Dict exposing (Dict)
import Task exposing (Task)


type alias Url =
  { href : String
  , auth : Maybe String
  , pathname : String
  , search : String
  , path : String
  -- , query : Dict String String -- need dict support
  }

type alias RequestId = String

type alias Request =
  { id : RequestId
  , method : String
  , url : Url
  -- , headers : Dict String String -- need dict support
  }
