module Routes.Article exposing (..)

import Dict
import Http
import Task exposing (Task, onError)
import Json.Decode exposing ((:=), decodeString, at)

import Config exposing (config)
import Router exposing (RouteHandler)
import Response
import Routes.Article.Decoder exposing (decodeArticleRoot, Article)



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
  decodeString decodeArticleRoot json
    |> Result.map .article


renderArticle : Result x Article -> String
renderArticle result =
  case result of
    Err _ -> "parsing error"
    Ok article -> article.id ++ " : " ++ article.title ++ " : " ++ toString article.resources
