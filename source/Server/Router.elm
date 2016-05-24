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
  (Method, Pattern, RouteHandler)

type alias Pattern =
  String

type Method =
  GET | POST | PUT | DELETE | OPTIONS | ALL | USE

type alias RouteHandler =
  Params -> Router

type alias Error =
  String -- TODO More useful error type

type alias Params =
  Dict String String


all : Pattern -> RouteHandler -> Route
all path callback =
  (ALL, path, callback)

use : Pattern -> RouteHandler -> Route
use path callback =
  (USE, path, callback)

get : Pattern -> RouteHandler -> Route
get path callback =
  (GET, path, callback)

post : Pattern -> RouteHandler -> Route
post path callback =
  (POST, path, callback)

put : Pattern -> RouteHandler -> Route
put path callback =
  (PUT, path, callback)

delete : Pattern -> RouteHandler -> Route
delete path callback =
  (DELETE, path, callback)

options : Pattern -> RouteHandler -> Route
options path callback =
  (OPTIONS, path, callback)



router : Routes -> Params -> Router
router routes params req =
  find (matchRoute req) routes
    |> doRoute req


paramRegex : Regex
paramRegex =
  regex "\\{([^/{}]+?)\\}"


createRouteRegex : Method -> Pattern -> Regex
createRouteRegex method pattern =
  let
    end = if method == USE then "" else "$"
  in
  regex ("^" ++ (Regex.replace Regex.All paramRegex (\{match} -> "([^/]+)") pattern) ++ end)


matchRoute : Request -> Route -> Bool
matchRoute req (method, pattern, _) =
  matchMethod method req.method
    && Regex.contains (createRouteRegex method pattern) req.url.path


matchMethod : Method -> String -> Bool
matchMethod targetMethod requestMethod =
  case targetMethod of
    -- TODO when ports supports tagged unions, req.method should be a Method
    USE -> True
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
    Just (method, pattern, callback) -> callback (createParams req method pattern) (updateSubrequest method pattern req)


createParams : Request -> Method -> Pattern -> Params
createParams req method pattern =
  let
    routeRegex = createRouteRegex method pattern
    -- TODO Separate and dry this shit up
    names = definitively (List.concatMap .submatches (Regex.find Regex.All paramRegex pattern))
    values = definitively (List.concatMap .submatches (Regex.find Regex.All routeRegex req.url.path))
  in
    Dict.fromList (zip names values)


updateSubrequest : Method -> Pattern -> Request -> Request
updateSubrequest method pattern req =
  let url = req.url in
  case method of
    USE -> { req
           | url = { url
                   | path = subPath method pattern url.path
                   , originalPath = Just url.path
                   }
           }
    _ -> req


subPath : Method -> Pattern -> String -> String
subPath method pattern path =
  let
    paramRegex = createRouteRegex method pattern
  in
    Regex.replace Regex.All paramRegex (\_ -> "") path


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
