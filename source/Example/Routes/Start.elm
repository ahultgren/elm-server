module Routes.Start exposing (..)


import Task exposing (Task, onError)

import Response
import Router exposing (RouteHandler)


start : RouteHandler
start req params =
  Task.succeed (Response.Ok "welcome!" Nothing)
