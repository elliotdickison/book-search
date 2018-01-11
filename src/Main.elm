module Main exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, type_, value)
import Html.Styled.Events exposing (onInput)
import Http
import Navigation
import Route exposing (Route(..))
import Data.Book as Book exposing (Book)
import View.App
import View.Book
import View.Input
import RemoteData exposing (RemoteData(..))
import Extra.RemoteData as RemoteData
import Service.Book
import Update.Extra exposing (andThen)


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> RouteChanged)
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { books : RemoteData Http.Error (List Book)
    , searchResults : RemoteData Http.Error (List Book)
    , route : Route
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( Model Loading NotAsked (Route.fromLocation location)
    , Service.Book.load
        |> RemoteData.sendRequest
        |> Cmd.map SetBooks
    )
        |> andThen update RequestSearchResults



-- UPDATE


type Msg
    = SetBooks (RemoteData Http.Error (List Book))
    | Search String
    | RequestSearchResults
    | SetSearchResults String (RemoteData Http.Error (List Book))
    | RouteChanged Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetBooks books ->
            { model | books = books } ! []

        Search query ->
            case model.route of
                Home q ->
                    case q of
                        Just q ->
                            model ! [ Route.modifyUrl (Home (Just query)) ]

                        Nothing ->
                            model ! [ Route.newUrl (Home (Just query)) ]

                _ ->
                    model ! []

        RequestSearchResults ->
            case model.route of
                Home (Just query) ->
                    if String.isEmpty query then
                        { model | searchResults = NotAsked } ! []
                    else
                        { model | searchResults = Loading }
                            ! [ Service.Book.searchAmazon query
                                    |> RemoteData.sendRequestDebounced "search" 200
                                    |> Cmd.map (SetSearchResults query)
                              ]

                _ ->
                    model ! []

        SetSearchResults query books ->
            case model.route of
                Home (Just q) ->
                    if query == q then
                        { model | searchResults = books } ! []
                    else
                        model ! []

                _ ->
                    model ! []

        RouteChanged route ->
            { model | route = route }
                ! []
                |> andThen update RequestSearchResults



-- VIEW


view : Model -> Html Msg
view model =
    let
        searchQuery =
            case model.route of
                Home (Just query) ->
                    query

                _ ->
                    ""
    in
        View.App.chrome
            [ View.Input.input [ type_ "text", value searchQuery, onInput Search ] []
            , viewBooks model.books
            , viewBooks model.searchResults
            ]


viewBooks : RemoteData Http.Error (List Book) -> Html Msg
viewBooks books =
    case books of
        NotAsked ->
            text ""

        Loading ->
            text "Loading..."

        Success books ->
            View.Book.grid books

        Failure _ ->
            text "Error"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
