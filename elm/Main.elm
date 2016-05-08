module Server (..) where

import Signal exposing (Mailbox, mailbox)
import Task exposing (Task, andThen, onError)
import Types exposing (Routes, Route, Request, Response, Params, RequestError)
import Dict
import Router
import Utils exposing (createResponse)
import Http


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
router =
  Router.create
    [ ("/", start)
    , ("/a/{article_id}", article)
    ]
    end


end : Task () Response -> Task () ()
end responseTask =
  responseTask `andThen` (\response -> send response)


start : Request -> Params -> Task () Response
start req params =
  Task.succeed (createResponse req "start")


article : Request -> Params -> Task () Response
article req params =
  getArticle (Dict.get "article_id" params)
  `andThen` (\article -> Task.succeed (createResponse req article))
  `onError` (\_ -> Task.succeed (createResponse req "404"))


apiBase : String
apiBase =
  "http://api.omni.se/v2"


getArticle : Maybe String -> Task RequestError String
getArticle id =
  case id of
    Nothing -> Task.fail (Types.ParamError "No such article")
    Just id -> Http.get (apiBase ++ "/articles/" ++ id)
      |> Task.mapError Types.HttpError
