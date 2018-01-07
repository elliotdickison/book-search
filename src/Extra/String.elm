module Extra.String exposing (dropRightOfChar, keepRightOfChar, toMaybe, dropTrailingParenthetical)

import Regex


dropRightOfChar : Char -> String -> String
dropRightOfChar char string =
    let
        firstIndex =
            string |> String.indices (String.fromChar char) |> List.head
    in
        case firstIndex of
            Just index ->
                String.left index string

            Nothing ->
                string


keepRightOfChar : Char -> String -> String
keepRightOfChar char string =
    let
        firstIndex =
            string |> String.indices (String.fromChar char) |> List.head
    in
        case firstIndex of
            Just index ->
                String.dropLeft (index + 1) string

            Nothing ->
                ""


toMaybe : String -> Maybe String
toMaybe string =
    if String.isEmpty string then
        Nothing
    else
        Just string


dropTrailingParenthetical : String -> String
dropTrailingParenthetical =
    Regex.replace Regex.All (Regex.regex "\\s*(\\([^(]+\\)|\\[[^[]+\\])\\s*$") (\_ -> "")
