port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)

import Task exposing (Task)
import Request exposing (Request, RequestId)
import Response exposing (Response, OutgoingResponse, toOutgoingResponse)


port request : (Request -> msg) -> Sub msg
port response : OutgoingResponse -> Cmd msg


start : (Request -> Task x Response) -> Program Never
start handleRequest =
  program
    { init = (model, Cmd.none)
    , view = view
    , update = update response
    , subscriptions = always (request <| incoming handleRequest)
    }


update : (OutgoingResponse -> Cmd msg) -> Cmd OutgoingResponse -> model -> (model, Cmd (Cmd msg))
update outgoing res model =
  (model, Cmd.map outgoing res)


incoming : (Request -> Task x Response) -> Request -> Cmd OutgoingResponse
incoming router req =
  router req
    |> Task.perform (fail req.id) (success req.id)


fail : RequestId -> x -> OutgoingResponse
fail id error =
  toOutgoingResponse id <| Response.ServerError "500" Nothing


success : RequestId -> Response -> OutgoingResponse
success id res =
  toOutgoingResponse id res


--------------------
-- Bullshit stuff --
--------------------

type alias Model = ()
model : Model
model = ()

view : Model -> Html a
view model =
  text "serisously wtf?"
