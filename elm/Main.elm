module Example exposing (..)


import Task exposing (Task, andThen, onError)
import Dict

import Server
import Request exposing (Request, RequestId)
import Response exposing (Response, OutgoingResponse, toOutgoingResponse)
import Router exposing (Router, RouteHandler)
import Http


type RequestError =
  HttpError Http.Error | ParamError String


main =
  Server.start handleRequest


handleRequest : Request -> Task Router.Error Response
handleRequest req =
  router req


router : Router
router =
  Router.router
    [ ("/", start)
    , ("/a/{article_id}", article)
    , (".*", notFound)
    ]


start : RouteHandler
start req params =
  Task.succeed (Response.Ok "welcome!" Nothing)


article : RouteHandler
article req params =
  getArticle (Dict.get "article_id" params)
  `andThen` (\article -> Task.succeed (Response.Ok article Nothing))
  `onError` (\_ -> Task.succeed (Response.NotFound "404" Nothing))


notFound : RouteHandler
notFound req params =
  Task.succeed (Response.NotFound "custom 404" Nothing)


apiBase : String
apiBase =
  "http://api.omni.se/v2"


getArticle : Maybe String -> Task RequestError String
getArticle id =
  case id of
    Nothing -> Task.fail (ParamError "No such article")
    Just id -> Http.get (apiBase ++ "/articles/" ++ id)
      |> Task.mapError HttpError
