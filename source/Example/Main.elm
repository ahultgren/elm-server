module Example exposing (..)


import Dict exposing (Dict)
import Task exposing (Task, andThen, onError)

import Server
import Request exposing (Request, RequestId)
import Response exposing (Response, OutgoingResponse, toOutgoingResponse)
import Router exposing (Router, RouteHandler)

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
    [ (Router.GET, "/", start)
    , (Router.GET, "/a/{article_id}", article)
    -- TODO Router.USE for matching start of path?
    , (Router.GET, "/test/.*", Router.router
      [ (Router.GET, "/a", testA)
      , (Router.GET, "/b", testB)
      ])
    , (Router.GET, ".*", notFound)
    ]
    Dict.empty


notFound : RouteHandler
notFound params req =
  Task.succeed (Response.NotFound "custom 404" Nothing)


testA : RouteHandler
testA params req =
  Task.succeed (Response.Ok "testA" Nothing)

testB : RouteHandler
testB params req =
  Task.succeed (Response.Ok "testB" Nothing)
