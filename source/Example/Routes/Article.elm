module Routes.Article exposing (..)

import Dict
import Http
import Task exposing (Task, onError)
import Json.Decode exposing ((:=), decodeString, at)

import Config exposing (config)
import Router exposing (RouteHandler)
import Response


type alias Article =
  { id : String
  , title : String
  }


type RequestError =
  HttpError Http.Error | ParamError String


article : RouteHandler
article params req =
  Task.map
    (\article -> Response.Ok (renderArticle article) Nothing)
    (getArticle (Dict.get "article_id" params))
  `onError` (\_ -> Task.succeed (Response.NotFound "404" Nothing))


getArticle : Maybe String -> Task RequestError (Result String Article)
getArticle id =
  case id of
    Nothing -> Task.fail (ParamError "No such article")
    Just id -> Http.get (config.apiBase ++ "/articles/" ++ id)
      |> Task.map parseArticle
      |> Task.mapError HttpError


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
