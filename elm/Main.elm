port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
import Task exposing (Task)

import Utils exposing (createResponse)
import Types exposing (Request, Response, Params)
import Router


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
router =
  Router.create
    [ ("/", start)
    ]
    end


start : Request -> Params -> Task () Response
start req params =
  Task.succeed (createResponse req "welcome!")


end : Task () Response -> Cmd Response
end resTask =
  Task.perform
    (\_ -> Response "?" "fuck")
    identity
    resTask


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
