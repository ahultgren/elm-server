module Router exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)
import Task exposing (Task)
import Request exposing (Request, RequestId)
import Response exposing (Response)


type alias Router =
  Request -> Task () Response

type alias Routes =
  List Route

type alias Route =
  (String, RouteHandler)

type alias RouteHandler =
  Request -> Params -> Task () Response

type alias Params =
  Dict String String


router : Routes -> Router
router routes req =
  List.filter (matchRoute req << fst) routes
    |> List.head
    |> doRoute req


paramRegex : Regex
paramRegex =
  regex "\\{([^/{}]+?)\\}"


createRouteRegex : String -> Regex
createRouteRegex pattern =
  regex ("^" ++ (Regex.replace Regex.All paramRegex (\{match} -> "([^/]+)") pattern) ++ "$")


matchRoute : Request -> String -> Bool
matchRoute req pattern =
  let
    routeRegex = createRouteRegex pattern
  in
    Regex.contains routeRegex req.url.path


-- TODO ErrorRoute fallback? Error -> Route. And a way to create empty params
doRoute : Request -> Maybe Route -> Task () Response
doRoute req route =
  case route of
    Nothing -> Task.succeed (Response.NotFound "404" Nothing)
    Just (pattern, callback) -> callback req (createParams req pattern)


createParams : Request -> String -> Params
createParams req pattern =
  let
    routeRegex = createRouteRegex pattern
    -- TODO Separate and dry this shit up
    names = definitively (List.concatMap .submatches (Regex.find Regex.All paramRegex pattern))
    values = definitively (List.concatMap .submatches (Regex.find Regex.All routeRegex req.url.path))
  in
    Dict.fromList (zip names values)


-------------
-- Helpers --
-------------


-- Prune all Nothings from a list of Maybe's
definitively : List (Maybe a) -> List a
definitively = List.filterMap identity


zip : List a -> List b -> List (a, b)
zip = List.map2 (,)
