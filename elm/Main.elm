port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
import Task

import Utils exposing (createResponse)
import Types exposing (Request, Response)


port request : (Request -> msg) -> Sub msg
port response : Response -> Cmd msg


main =
  program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


router : Request -> Cmd Response
router req =
  Task.perform
    (\_ -> createResponse req "500")
    identity
    (Task.succeed (createResponse req req.url.path))


update : Cmd Response -> Model -> (Model, Cmd (Cmd Response))
update res model =
  (model, Cmd.map response res)


subscriptions : Model -> Sub (Cmd Response)
subscriptions model =
  request router


--------------------
-- Bullshit stuff --
--------------------

type alias Model = ()
model : Model
model = ()

view : Model -> Html a
view model =
  text "serisously wtf?"
