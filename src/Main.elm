module Main exposing (..)

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, type_, value)
import Html.Styled.Events exposing (onInput)
import Http
import Debouncer
import Data.Book as Book exposing (Book)
import View.App
import View.Book
import RemoteData exposing (RemoteData(..))


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { books : RemoteData Http.Error (List Book)
    , searchQuery : String
    , searchResults : RemoteData Http.Error (List Book)
    }


init : ( Model, Cmd Msg )
init =
    ( Model Loading "" NotAsked
    , loadBooks
    )



-- UPDATE


type Msg
    = SetBooks (RemoteData Http.Error (List Book))
    | Search String
    | SetSearchResults (RemoteData Http.Error (List Book))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetBooks books ->
            { model | books = books } ! []

        Search query ->
            let
                results =
                    if RemoteData.isSuccess model.searchResults then
                        model.searchResults
                    else
                        Loading
            in
                { model | searchQuery = query, searchResults = results }
                    ! [ loadGoogleBooks model.searchQuery |> debounceSendRemoteData "search" 300 SetSearchResults
                      ]

        SetSearchResults books ->
            { model | searchResults = books } ! []



-- VIEW


view : Model -> Html Msg
view model =
    View.App.chrome
        [ input [ type_ "text", value model.searchQuery, onInput Search ] []
        , viewBooks model.books
        , viewBooks model.searchResults
        ]


viewBooks : RemoteData Http.Error (List Book) -> Html Msg
viewBooks books =
    case books of
        NotAsked ->
            text "Loading..."

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



-- HTTP


debounceSendRemoteData : String -> Float -> (RemoteData Http.Error a -> Msg) -> Http.Request a -> Cmd Msg
debounceSendRemoteData key delay tagger request =
    Debouncer.debounce key delay (RemoteData.fromResult >> tagger) (Http.toTask request)


loadBooks : Cmd Msg
loadBooks =
    Http.get "https://book-list-1265b.firebaseio.com/books.json" Book.decodeList
        |> RemoteData.sendRequest
        |> Cmd.map SetBooks


loadGoogleBooks : String -> Http.Request (List Book)
loadGoogleBooks query =
    Http.get ("https://www.googleapis.com/books/v1/volumes?printType=books&maxResults=40&orderBy=relevance&q=" ++ query) Book.decodeGoogleList
