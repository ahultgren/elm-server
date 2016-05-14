port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
import Task exposing (Task, andThen, onError)
import Dict

import Request exposing (Request, RequestId)
import Response exposing (Response)
import Router exposing (Router, RouteHandler)
import Http


type RequestError =
  HttpError Http.Error | ParamError String


port request : (Request -> msg) -> Sub msg
port response : Response -> Cmd msg


main =
  program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


handleRequest : Request -> Cmd Response
handleRequest req =
  router req
    |> Task.perform (fail req.id) identity


router : Router
router =
  Router.router
    [ ("/", start)
    , ("/a/{article_id}", article)
    , (".*", notFound)
    ]


fail : RequestId -> x -> Response
fail id error =
  Response id "500"


start : RouteHandler
start req params =
  Task.succeed (Response req.id "welcome!")


article : RouteHandler
article req params =
  getArticle (Dict.get "article_id" params)
  `andThen` (\article -> Task.succeed (Response req.id article))
  `onError` (\_ -> Task.succeed (Response req.id "404"))


notFound : RouteHandler
notFound req params =
  Task.succeed (Response req.id "custom 404")


apiBase : String
apiBase =
  "http://api.omni.se/v2"


getArticle : Maybe String -> Task RequestError String
getArticle id =
  case id of
    Nothing -> Task.fail (ParamError "No such article")
    Just id -> Http.get (apiBase ++ "/articles/" ++ id)
      |> Task.mapError HttpError


update : Cmd Response -> Model -> (Model, Cmd (Cmd Response))
update res model =
  (model, Cmd.map response res)


subscriptions : Model -> Sub (Cmd Response)
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
