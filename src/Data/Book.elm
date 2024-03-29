module Data.Book exposing (Book, fullTitle, decoder, listDecoder, amazonListDecoder)

import Json.Decode as Json exposing (Decoder)
import Extra.Json.Decode as Json
import Extra.String as String
import Time exposing (Time)
import Date


type alias Metadata =
    { subtitle : Maybe String
    , coverUrl : Maybe String
    , asin : Maybe String
    , isbn : Maybe String
    , pageCount : Maybe Int
    , publishedAt : Maybe Time
    , publishedBy : Maybe String
    }


type alias Book =
    { id : String
    , title : String
    , authors : List String
    , metadata : Metadata
    }


fullTitle : Book -> String
fullTitle book =
    let
        subtitle =
            book.metadata.subtitle
                |> Maybe.map (\t -> ": " ++ t)
                |> Maybe.withDefault ""
    in
        book.title ++ subtitle


metadataDecoder : Decoder Metadata
metadataDecoder =
    Json.map7 Metadata
        (Json.field "subtitle" Json.string |> Json.maybe)
        (Json.field "coverUrl" Json.string |> Json.maybe)
        (Json.field "asin" Json.string |> Json.maybe)
        (Json.field "isbn" Json.string |> Json.maybe)
        (Json.field "pageCount" Json.int |> Json.maybe)
        (Json.field "publishedAt" Json.float |> Json.maybe)
        (Json.field "publishedBy" Json.string |> Json.maybe)


decoder : Decoder Book
decoder =
    Json.map4 Book
        (Json.field "id" Json.string)
        (Json.field "title" Json.string)
        (Json.field "authors" (Json.list Json.string))
        (Json.field "metadata" metadataDecoder)


listDecoder : Decoder (List Book)
listDecoder =
    Json.tolerantList decoder


amazonItemTitleDecoder : Decoder String
amazonItemTitleDecoder =
    Json.field "ItemAttributes" (Json.listHead (Json.field "Title" (Json.listHead Json.string)))
        |> Json.map (String.dropRightOfChar ':')
        |> Json.map String.dropTrailingParenthetical
        |> Json.map String.trim


amazonItemSubtitleDecoder : Decoder (Maybe String)
amazonItemSubtitleDecoder =
    Json.field "ItemAttributes" (Json.listHead (Json.field "Title" (Json.listHead Json.string)))
        |> Json.map (String.keepRightOfChar ':')
        |> Json.map String.dropTrailingParenthetical
        |> Json.map String.trim
        |> Json.map String.toMaybe


amazonItemPublishedAtDecoder : Decoder (Maybe Time)
amazonItemPublishedAtDecoder =
    Json.field "ItemAttributes" (Json.listHead (Json.field "PublicationDate" (Json.listHead Json.date)))
        |> Json.map Date.toTime
        |> Json.maybe


amazonItemIsbnDecoder : Decoder String
amazonItemIsbnDecoder =
    Json.field "ItemAttributes" (Json.listHead (Json.field "ISBN" (Json.listHead Json.string)))


amazonItemMetadataDecoder : Decoder Metadata
amazonItemMetadataDecoder =
    Json.map7 Metadata
        amazonItemSubtitleDecoder
        (Json.field "LargeImage" (Json.listHead (Json.field "URL" (Json.listHead Json.string))) |> Json.maybe)
        (Json.field "ASIN" (Json.listHead Json.string) |> Json.maybe)
        (amazonItemIsbnDecoder |> Json.maybe)
        (Json.field "ItemAttributes" (Json.listHead (Json.field "NumberOfPages" (Json.listHead Json.stringInt))) |> Json.maybe)
        amazonItemPublishedAtDecoder
        (Json.field "ItemAttributes" (Json.listHead (Json.field "Publisher" (Json.listHead Json.string))) |> Json.maybe)


amazonItemDecoder : Decoder Book
amazonItemDecoder =
    Json.map4 Book
        amazonItemIsbnDecoder
        amazonItemTitleDecoder
        (Json.field "ItemAttributes" (Json.listHead (Json.field "Author" (Json.list Json.string))))
        amazonItemMetadataDecoder


amazonListDecoder : Decoder (List Book)
amazonListDecoder =
    Json.tolerantList amazonItemDecoder
