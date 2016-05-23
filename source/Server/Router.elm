module Router exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)
import Task exposing (Task)
import Request exposing (Request, RequestId)
import Response exposing (Response)


type alias Router =
  Request -> Task Error Response

type alias Routes =
  List Route

type alias Route =
  (Method, String, RouteHandler)

type Method =
  GET | POST | PUT | DELETE | OPTIONS | ALL

type alias RouteHandler =
  Params -> Router

type alias Error =
  String -- TODO More useful error type

type alias Params =
  Dict String String


router : Routes -> Params -> Router
router routes params req =
  find (matchRoute req) routes
    |> doRoute req


paramRegex : Regex
paramRegex =
  regex "\\{([^/{}]+?)\\}"


createRouteRegex : String -> Regex
createRouteRegex pattern =
  regex ("^" ++ (Regex.replace Regex.All paramRegex (\{match} -> "([^/]+)") pattern) ++ "$")


matchRoute : Request -> Route -> Bool
matchRoute req (method, pattern, _) =
  matchMethod method req.method
    && Regex.contains (createRouteRegex pattern) req.url.path


matchMethod : Method -> String -> Bool
matchMethod targetMethod requestMethod =
  case targetMethod of
    ALL -> True
    GET -> requestMethod == "GET"
    POST -> requestMethod == "POST"
    PUT -> requestMethod == "PUT"
    DELETE -> requestMethod == "DELETE"
    OPTIONS -> requestMethod == "OPTIONS"


-- TODO ErrorRoute fallback? Error -> Route. And a way to create empty params
doRoute : Request -> Maybe Route -> Task Error Response
doRoute req route =
  case route of
    Nothing -> Task.succeed (Response.NotFound "404" Nothing)
    Just (_, pattern, callback) -> callback (createParams req pattern) req


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


-- Get the first matching element of a list. Should be more lazy than filter
find : (a -> Bool) -> List a -> Maybe a
find predicate list =
  case list of
    [] -> Nothing
    head::tail -> if predicate head then Just head else find predicate tail
