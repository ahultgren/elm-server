module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)


start : (a -> Model -> ( Model, Cmd a )) -> Sub a -> Program Never
start update subscriptions =
  program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = always subscriptions
    }

--------------------
-- Bullshit stuff --
--------------------

type alias Model = ()
model : Model
model = ()

view : Model -> Html a
view model =
  text "serisously wtf?"
