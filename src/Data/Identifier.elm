module Data.Identifier exposing (Identifier(..), coverUrl, isIsbn, decodeList, decodeGoogleList)

import Json.Decode as Json


type Identifier
    = GoogleBookId String
    | OpenLibraryId String
    | Isbn10 String
    | Isbn13 String


isIsbn : Identifier -> Bool
isIsbn id =
    case id of
        Isbn10 _ ->
            True

        Isbn13 _ ->
            True

        _ ->
            False


coverUrl : Identifier -> String
coverUrl id =
    case id of
        GoogleBookId id ->
            "https://books.google.com/books/content?id=" ++ id ++ "&printsec=frontcover&img=1&zoom=2&source=gbs_api"

        OpenLibraryId id ->
            "https://covers.openlibrary.org/b/id/" ++ id ++ "-L.jpg"

        Isbn10 isbn ->
            "https://covers.openlibrary.org/b/isbn/" ++ isbn ++ "-L.jpg"

        Isbn13 isbn ->
            "https://covers.openlibrary.org/b/isbn/" ++ isbn ++ "-L.jpg"


decodeList : Json.Decoder (List Identifier)
decodeList =
    Json.map3 (\a b c -> List.filterMap identity [ a, b, c ])
        (Json.field "googleBookId" Json.string |> Json.map GoogleBookId |> Json.maybe)
        (Json.field "isbn13" Json.string |> Json.map Isbn13 |> Json.maybe)
        (Json.field "isbn10" Json.string |> Json.map Isbn10 |> Json.maybe)


decodeGoogle : Json.Decoder (Maybe Identifier)
decodeGoogle =
    Json.map2
        (\kind value ->
            case kind of
                "ISBN_13" ->
                    Just (Isbn13 value)

                "ISBN_10" ->
                    Just (Isbn10 value)

                _ ->
                    Nothing
        )
        (Json.field "type" Json.string)
        (Json.field "identifier" Json.string)


decodeGoogleList : Json.Decoder (List Identifier)
decodeGoogleList =
    Json.map2 (\googleBookId industryIds -> googleBookId :: (List.filterMap identity industryIds))
        (Json.field "id" Json.string |> Json.map GoogleBookId)
        (Json.at [ "volumeInfo", "industryIdentifiers" ] (Json.list decodeGoogle))
