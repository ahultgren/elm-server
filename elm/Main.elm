module Server (..) where

import Signal
import Dict exposing (Dict)

-- Types

type alias Url =
  { href : String
  , auth : Maybe String
  , pathname : String
  , search : String
  , path : String
  -- , query : Dict String String -- need dict support
  }

type alias Request =
  { id : String
  , method : String
  , url : Url
  -- , headers : Dict String String -- need dict support
  }

type alias Response =
  { id : String
  , body : String
  }


-- Ports

port request : Signal Request

port response : Signal Response
port response = Signal.map router request


router : Request -> Response
router req =
  { id = req.id
  , body = req.url.path
  }
