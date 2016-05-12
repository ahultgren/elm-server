module Router exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)
import Task exposing (Task)
import Types exposing (Routes, Route, Router, Request, Response, Params)
import Utils exposing (createResponse)


create : Routes -> (Task () Response -> Cmd Response) -> Router
create routes end req =
  List.filter (matchRoute req << fst) routes
    |> List.head
    |> doRoute req
    |> end


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
    Nothing -> Task.succeed (createResponse req "404")
    Just (pattern, callback) -> callback req (createParams req pattern)


zip : List a -> List b -> List (a, b)
zip = List.map2 (,)


definitively : List (Maybe a) -> List a
definitively = List.filterMap identity


createParams : Request -> String -> Params
createParams req pattern =
  let
    routeRegex = createRouteRegex pattern
    -- TODO Separate and dry this shit up
    names = definitively (List.concatMap .submatches (Regex.find Regex.All paramRegex pattern))
    values = definitively (List.concatMap .submatches (Regex.find Regex.All routeRegex req.url.path))
  in
    Dict.fromList (zip names values)