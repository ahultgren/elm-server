module Routes.Start exposing (..)


import Task exposing (Task, onError)

import Response
import Router exposing (RouteHandler)


start : RouteHandler
start params req =
  Task.succeed (Response.Ok "welcome!" Nothing)
