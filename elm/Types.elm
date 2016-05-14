module Types exposing (..)

import Dict exposing (Dict)
import Task exposing (Task)
import Http

-- TODO This feels like the wrong way to structure things...

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

type alias Response =
  { id : RequestId
  , body : String
  }

type alias Params =
  Dict String String

type alias Route =
  (String, (Request -> Params -> Task () Response))

type alias Routes =
  List Route

type alias Router =
  Request -> Task () Response

type RequestError =
  HttpError Http.Error | ParamError String
