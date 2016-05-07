module Server (..) where

import Signal exposing (Mailbox, mailbox)
import Task exposing (Task, andThen, onError)
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


-- Mailboxes

responseMailbox : Mailbox Response
responseMailbox = mailbox {id = "", body = ""}


send : Response -> Task x ()
send =
  Signal.send responseMailbox.address


-- Ports

port request : Signal Request

port response : Signal Response
port response = responseMailbox.signal

port temp : Signal (Task () ())
port temp = Signal.map router request


-- Controllers

router : Request -> Task () ()
router req =
  case req.url.path of
    _ -> getArticle "test"
      `andThen` (\article -> send (createResponse req article))


getArticle : String -> Task () String
getArticle id =
  -- TODO Get real article
  Task.succeed ("test article: " ++ id)


createResponse : Request -> String -> Response
createResponse req body =
  { id = req.id
  , body = body
  }
