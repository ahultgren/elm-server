module Example exposing (..)


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
    [ ("/", start)
    , ("/a/{article_id}", article)
    , (".*", notFound)
    ]


notFound : RouteHandler
notFound req params =
  Task.succeed (Response.NotFound "custom 404" Nothing)
