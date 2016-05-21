module Example exposing (..)


import Task exposing (Task, andThen, onError)
import Dict
import Json.Decode exposing ((:=), decodeString, at)

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
  Task.map
    (\article -> Response.Ok (renderArticle article) Nothing)
    (getArticle (Dict.get "article_id" params))
  `onError` (\_ -> Task.succeed (Response.NotFound "404" Nothing))


notFound : RouteHandler
notFound req params =
  Task.succeed (Response.NotFound "custom 404" Nothing)


apiBase : String
apiBase =
  "http://localhost:5000/v2"


getArticle : Maybe String -> Task RequestError (Result String Article)
getArticle id =
  case id of
    Nothing -> Task.fail (ParamError "No such article")
    Just id -> Http.get (apiBase ++ "/articles/" ++ id)
      |> Task.map parseArticle
      |> Task.mapError HttpError


type alias Article =
  { id : String
  , title : String
  }

parseArticle : String -> Result String Article
parseArticle json =
  decodeString (Json.Decode.object2 Article
    (at ["article", "id"] Json.Decode.string)
    (at ["article", "title"] Json.Decode.string)) json


renderArticle : Result x Article -> String
renderArticle result =
  case result of
    Err _ -> "parsing error"
    Ok article -> article.id ++ " : " ++ article.title
