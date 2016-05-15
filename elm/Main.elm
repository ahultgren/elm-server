port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
import Task exposing (Task, andThen, onError)
import Dict

import Request exposing (Request, RequestId)
import Response exposing (Response, OutgoingResponse, toOutgoingResponse)
import Router exposing (Router, RouteHandler)
import Http


type RequestError =
  HttpError Http.Error | ParamError String


port request : (Request -> msg) -> Sub msg
port response : OutgoingResponse -> Cmd msg


main =
  program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


handleRequest : Request -> Cmd OutgoingResponse
handleRequest req =
  router req
    |> Task.perform (fail req.id) (success req.id)


router : Router
router =
  Router.router
    [ ("/", start)
    , ("/a/{article_id}", article)
    , (".*", notFound)
    ]


fail : RequestId -> x -> OutgoingResponse
fail id error =
  toOutgoingResponse id <| Response.ServerError "500" Nothing


success : RequestId -> Response -> OutgoingResponse
success id res =
  toOutgoingResponse id res


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


update : Cmd OutgoingResponse -> Model -> (Model, Cmd (Cmd OutgoingResponse))
update res model =
  (model, Cmd.map response res)


subscriptions : Model -> Sub (Cmd OutgoingResponse)
subscriptions model =
  request handleRequest


--------------------
-- Bullshit stuff --
--------------------

type alias Model = ()
model : Model
model = ()

view : Model -> Html a
view model =
  text "serisously wtf?"
