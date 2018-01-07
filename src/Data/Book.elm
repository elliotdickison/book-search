module Data.Book exposing (Book, decode, decodeList, decodeGoogleList, coverUrl)

import Time exposing (Time)
import Json.Decode as Json
import Data.Identifier as Identifier exposing (Identifier(..))


type alias Book =
    { identifiers : List Identifier
    , title : String
    , subtitle : Maybe String
    , authors : List String
    , description : Maybe String
    , pageCount : Maybe Int
    , publishedAt : Maybe Time
    , publisher : Maybe String
    }


decode : Json.Decoder Book
decode =
    Json.map8 Book
        Identifier.decodeList
        (Json.field "title" Json.string)
        (Json.field "subtitle" Json.string |> Json.maybe)
        (Json.field "authors" (Json.list Json.string))
        (Json.field "description" Json.string |> Json.maybe)
        (Json.field "pageCount" Json.int |> Json.maybe)
        (Json.field "publishedAt" Json.float |> Json.maybe)
        (Json.field "publisher" Json.string |> Json.maybe)


decodeList : Json.Decoder (List Book)
decodeList =
    Json.list decode


decodeGoogleBook : Json.Decoder (Maybe Book)
decodeGoogleBook =
    Json.oneOf
        [ Json.map8 Book
            Identifier.decodeGoogleList
            (Json.at [ "volumeInfo", "title" ] Json.string)
            (Json.at [ "volumeInfo", "subtitle" ] Json.string |> Json.maybe)
            (Json.at [ "volumeInfo", "authors" ] (Json.list Json.string))
            (Json.at [ "volumeInfo", "description" ] Json.string |> Json.maybe)
            (Json.at [ "volumeInfo", "pageCount" ] Json.int |> Json.maybe)
            (Json.at [ "volumeInfo", "publishedDate" ] Json.float |> Json.maybe)
            (Json.at [ "volumeInfo", "publisher" ] Json.string |> Json.maybe)
            |> Json.map
                (\book ->
                    if hasIsbn book then
                        Just book
                    else
                        Nothing
                )
        , Json.succeed Nothing
        ]


decodeGoogleList : Json.Decoder (List Book)
decodeGoogleList =
    Json.field "items"
        (Json.list decodeGoogleBook |> Json.map (List.filterMap identity))


hasIsbn : Book -> Bool
hasIsbn book =
    List.foldl (\id pass -> pass || Identifier.isIsbn id) False book.identifiers


coverUrl : Book -> Maybe String
coverUrl book =
    book.identifiers |> List.map Identifier.coverUrl |> List.head
