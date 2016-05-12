port module Server exposing (..)


import Html.App exposing (program)
import Html exposing (Html, text)
import Task exposing (Task, andThen, onError)
import Dict

import Utils exposing (createResponse)
import Types exposing (Request, Response, Params, RequestError)
import Router
import Http


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
    , ("/a/{article_id}", article)
    ]
    end


end : Task () Response -> Cmd Response
end resTask =
  Task.perform
    (\_ -> Response "?" "fuck")
    identity
    resTask


start : Request -> Params -> Task () Response
start req params =
  Task.succeed (createResponse req "welcome!")


article : Request -> Params -> Task () Response
article req params =
  getArticle (Dict.get "article_id" params)
  `andThen` (\article -> Task.succeed (createResponse req article))
  `onError` (\_ -> Task.succeed (createResponse req "404"))


apiBase : String
apiBase =
  "http://api.omni.se/v2"


getArticle : Maybe String -> Task RequestError String
getArticle id =
  case id of
    Nothing -> Task.fail (Types.ParamError "No such article")
    Just id -> Http.get (apiBase ++ "/articles/" ++ id)
      |> Task.mapError Types.HttpError


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
