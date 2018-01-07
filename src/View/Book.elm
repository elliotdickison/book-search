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
            , width (pct 14.28)
            ]
        ]
        [ cover book
        , div
            [ css [ marginTop (px 10) ] ]
            [ text book.title ]
        , div
            [ css [ color (hex "999"), fontSize (Css.em 0.8) ] ]
            [ book.authors |> String.join ", " |> text ]
        ]


cover : Book -> Html msg
cover book =
    div
        [ css
            [ paddingTop (pct 150)
            , height (px 0)
            , width (pct 100)
            , backgroundImage (book.metadata.coverUrl |> Maybe.withDefault "" |> url)
            , backgroundSize Css.cover
            , backgroundPosition center
            , backgroundRepeat noRepeat
            ]
        , title book.title
        ]
        []
