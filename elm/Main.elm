module Server (..) where

import Signal exposing (Mailbox, mailbox)
import Task exposing (Task, andThen, onError)
import Types exposing (Routes, Route, Request, Response, Params)
import Router
import Utils exposing (createResponse)


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
    ]
    end


end : Task () Response -> Task () ()
end responseTask =
  responseTask `andThen` (\response -> send response)


start : Request -> Params -> Task () Response
start req params =
  Task.succeed "asdasd"
    `andThen` (\article -> Task.succeed (createResponse req article))


getArticle : String -> Task () String
getArticle id =
  -- TODO Get real article
  Task.succeed ("test article: " ++ id)
