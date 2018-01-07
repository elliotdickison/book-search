module Extra.Json.Decode exposing (listHead, stringInt, date)

import Json.Decode as Json exposing (Decoder)
import Date exposing (Date)


listHead : Decoder a -> Decoder a
listHead itemDecoder =
    let
        getHead list =
            case List.head list of
                Just item ->
                    Json.succeed item

                Nothing ->
                    Json.fail "Found an empty list when at least one item was expected."
    in
        Json.list itemDecoder |> Json.andThen getHead


stringInt : Decoder Int
stringInt =
    let
        toInt string =
            case String.toInt string of
                Ok int ->
                    Json.succeed int

                Err error ->
                    Json.fail error
    in
        Json.andThen toInt Json.string


date : Decoder Date
date =
    let
        getDate result =
            case result of
                Ok date ->
                    Json.succeed date

                Err error ->
                    Json.fail error
    in
        Json.string
            |> Json.map Date.fromString
            |> Json.andThen getDate
