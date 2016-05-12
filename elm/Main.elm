port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
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


router : Request -> Response
router req =
  createResponse req req.url.path


update : Response -> Model -> (Model, Cmd Response)
update res model =
  (model, response res)


subscriptions : Model -> Sub Response
subscriptions model =
  request router


--------------------
-- Bullshit stuff --
--------------------

type alias Model = ()
model : Model
model = ()

view : Model -> Html Response
view model =
  text "serisously wtf?"
