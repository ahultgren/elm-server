module Example exposing (..)


import Dict exposing (Dict)
import Task exposing (Task, andThen, onError)

import Server
import Request exposing (Request, RequestId)
import Response exposing (Response, OutgoingResponse, toOutgoingResponse)
import Router exposing (Router, RouteHandler, get, use)

import Routes.Article exposing (article)
import Routes.Start exposing (start)


main =
  Server.start handleRequest


handleRequest : Request -> Task Router.Error Response
handleRequest req =
  router req


router : Router
router =
  Router.router
    [ get "/" start
    , get "/a/{article_id}" article
    , use "/test" (Router.router
      [ get "/a" testA
      , get "/b" testB
      ])
    , get ".*" notFound
    ]
    Dict.empty


notFound : RouteHandler
notFound params req =
  Task.succeed (Response.NotFound "custom 404" Nothing)


testA : RouteHandler
testA params req =
  Task.succeed (Response.Ok (Maybe.withDefault "" req.url.originalPath ++ " -> " ++ req.url.path) Nothing)

testB : RouteHandler
testB params req =
  Task.succeed (Response.Ok "testB" Nothing)
