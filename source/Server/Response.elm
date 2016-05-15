module Response exposing (..)


import Request


type alias OutgoingResponse =
  { id : Request.RequestId
  , body : Body
  , statusCode : Int
  }

type Response =
  Ok Body (Maybe Headers)
  | ServerError Body (Maybe Headers)
  | NotFound Body (Maybe Headers)
  -- TODO let's await tagged union port support before bothering with anything else
  -- | BadRequest Body (Maybe Headers)
  -- | Redirect RedirectType Location (Maybe Headers)

type alias Body =
  String

type alias Headers =
  String -- need port dict support

type alias RedirectType =
  StatusCode

type alias StatusCode =
  Int

type alias Location =
  String


toOutgoingResponse : Request.RequestId -> Response -> OutgoingResponse
toOutgoingResponse id res =
  let
    body = (case res of
      Ok body _ -> body
      ServerError body _ -> body
      NotFound body _ -> body
    )
    statusCode = (case res of
      Ok _ _ -> 200
      ServerError _ _ -> 500
      NotFound _ _ -> 404
    )
  in
    OutgoingResponse id body statusCode
