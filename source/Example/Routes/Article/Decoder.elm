module Routes.Article.Decoder exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:))

type alias ArticleRoot =
  { article: Article
  }

type alias Article =
  { id : String
  , title : String
  , topics : List Tag
  , authors : List Author
  , version : ArticleVersion
  , category : String
  , isDeleted : Bool
  , newsValue : Int
  , published : String
  , resources : List Resource
  , newsLifetime : Int
  , type' : String
  , machineTags : List Tag
  , story : ArticleStory
  , displaySize : String
  , categoryObject : ArticleCategoryObject
  , groupSize : Maybe Int
  }

type alias ArticleVersion =
  { sequenceNo : Int
  }

type alias ArticleStory =
  { id : String
  , title : String
  }

type alias ArticleCategoryObjectColor =
  { red : Int
  , green : Int
  , blue : Int
  }

type alias ArticleCategoryObject =
  { weight : Float
  , id : String
  , title : String
  , color : ArticleCategoryObjectColor
  , visible : Bool
  , public : Bool
  , order : Int
  , default : Float
  , slug : String
  }

type alias Tag =
  { id : String
  , type' : String
  , title : String
  }

type alias Author =
  { id : String
  , title : String
  }

type alias ImageResource = { type' : String, imageId : String }
type Resource
  = TitleResource String
  | ImageResourceEnum ImageResource
  | UnknownResource String


decodeArticleRoot : Json.Decode.Decoder ArticleRoot
decodeArticleRoot =
  Json.Decode.succeed ArticleRoot
    |: ("article" := decodeArticle)

decodeArticle : Json.Decode.Decoder Article
decodeArticle =
  Json.Decode.succeed Article
    |: ("id" := Json.Decode.string)
    |: ("title" := Json.Decode.string)
    |: ("topics" := Json.Decode.list decodeTag)
    |: ("authors" := Json.Decode.list decodeAuthor)
    |: ("version" := decodeArticleVersion)
    |: ("category" := Json.Decode.string)
    |: ("isDeleted" := Json.Decode.bool)
    |: ("newsValue" := Json.Decode.int)
    |: ("published" := Json.Decode.string)
    |: ("resources" := Json.Decode.list decodeResource)
    |: ("newsLifetime" := Json.Decode.int)
    |: ("type" := Json.Decode.string)
    |: ("machineTags" := Json.Decode.list decodeTag)
    |: ("story" := decodeArticleStory)
    |: ("displaySize" := Json.Decode.string)
    |: ("categoryObject" := decodeArticleCategoryObject)
    |: Json.Decode.maybe ("groupSize" := Json.Decode.int)

decodeArticleVersion : Json.Decode.Decoder ArticleVersion
decodeArticleVersion =
  Json.Decode.succeed ArticleVersion
    |: ("sequenceNo" := Json.Decode.int)

decodeArticleStory : Json.Decode.Decoder ArticleStory
decodeArticleStory =
  Json.Decode.succeed ArticleStory
    |: ("id" := Json.Decode.string)
    |: ("title" := Json.Decode.string)

decodeArticleCategoryObjectColor : Json.Decode.Decoder ArticleCategoryObjectColor
decodeArticleCategoryObjectColor =
  Json.Decode.succeed ArticleCategoryObjectColor
    |: ("red" := Json.Decode.int)
    |: ("green" := Json.Decode.int)
    |: ("blue" := Json.Decode.int)

decodeArticleCategoryObject : Json.Decode.Decoder ArticleCategoryObject
decodeArticleCategoryObject =
  Json.Decode.succeed ArticleCategoryObject
    |: ("weight" := Json.Decode.float)
    |: ("id" := Json.Decode.string)
    |: ("title" := Json.Decode.string)
    |: ("color" := decodeArticleCategoryObjectColor)
    |: ("visible" := Json.Decode.bool)
    |: ("public" := Json.Decode.bool)
    |: ("order" := Json.Decode.int)
    |: ("default" := Json.Decode.float)
    |: ("slug" := Json.Decode.string)

decodeTag : Json.Decode.Decoder Tag
decodeTag =
  Json.Decode.succeed Tag
    |: ("id" := Json.Decode.string)
    |: ("type" := Json.Decode.string)
    |: ("title" := Json.Decode.string)

decodeAuthor : Json.Decode.Decoder Author
decodeAuthor =
  Json.Decode.succeed Author
    |: ("id" := Json.Decode.string)
    |: ("title" := Json.Decode.string)

decodeResource : Json.Decode.Decoder Resource
decodeResource =
  ("type" := Json.Decode.string)
    `Json.Decode.andThen` decodeResourceEnum

decodeResourceEnum : String -> Json.Decode.Decoder Resource
decodeResourceEnum type' =
  case type' of
    "title" -> Json.Decode.succeed TitleResource
      |: ("type" := Json.Decode.string)
    "image" -> Json.Decode.succeed ImageResource
      |: ("type" := Json.Decode.string)
      |: ("imageId" := Json.Decode.string)
      |> Json.Decode.map ImageResourceEnum
    other -> Json.Decode.succeed <| UnknownResource other
