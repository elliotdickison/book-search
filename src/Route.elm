module Route
    exposing
        ( Route(..)
        , fromLocation
        , toHref
        , toOnClick
        , toUrl
        , newUrl
        , modifyUrl
        )

import Http
import Html exposing (Attribute)
import Html.Attributes
import Html.Events
import Json.Decode as Json
import Navigation exposing (Location)
import UrlParser as Url
    exposing
        ( (</>)
        , (<?>)
        , s
        , string
        , stringParam
        , top
        , map
        , oneOf
        )


type Route
    = ReadingList (Maybe String)
    | History
    | NotFound


route : Url.Parser (Route -> a) a
route =
    oneOf
        [ map ReadingList (s "src" </> s "Main.elm" <?> stringParam "q")
        , map History (s "src" </> s "Main.elm" </> s "history")
        ]


toUrl : Route -> String
toUrl route =
    case route of
        ReadingList Nothing ->
            "/src/Main.elm"

        ReadingList (Just q) ->
            "/src/Main.elm?q=" ++ (Http.encodeUri q)

        History ->
            "/src/Main.elm/history"

        NotFound ->
            "/src/Main.elm/404"


toHref : Route -> Attribute msg
toHref route =
    Html.Attributes.href <| toUrl route


toOnClick : (Route -> msg) -> Route -> Attribute msg
toOnClick toMsg route =
    Html.Events.onWithOptions
        "click"
        { preventDefault = True, stopPropagation = False }
        (Json.succeed <| toMsg route)


fromLocation : Location -> Route
fromLocation location =
    location
        |> Url.parsePath route
        |> Maybe.withDefault NotFound


newUrl : Route -> Cmd msg
newUrl route =
    Navigation.newUrl <| toUrl route


modifyUrl : Route -> Cmd msg
modifyUrl route =
    Navigation.modifyUrl <| toUrl route
