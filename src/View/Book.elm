module View.Book exposing (grid, card)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, title)
import Data.Book as Book exposing (Book)


grid : List Book -> Html msg
grid books =
    div
        [ css
            [ displayFlex
            , flexDirection row
            , flexWrap wrap
            , alignItems flexStart
            , justifyContent flexStart
            ]
        ]
        (List.map card books)


card : Book -> Html msg
card book =
    div
        [ css
            [ padding (px 10)
            , maxWidth minContent
            ]
        ]
        [ cover 160 book
        , div
            [ css [ marginTop (px 10) ] ]
            [ text book.title ]
        , div
            [ css [ color (hex "999"), fontSize (Css.em 0.8) ] ]
            [ book.authors |> String.join ", " |> text ]
        ]


cover : Float -> Book -> Html msg
cover width book =
    let
        coverUrl =
            Book.coverUrl book |> Maybe.withDefault ""
    in
        div
            [ css
                [ paddingTop (pct 150)
                , height (px 0)
                , Css.width (px width)
                , backgroundImage (url coverUrl)
                , backgroundSize Css.cover
                , backgroundPosition center
                , backgroundRepeat noRepeat
                ]
            , title book.title
            ]
            []
