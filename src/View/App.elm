module View.App exposing (chrome)

import Css exposing (..)
import Css.Foreign exposing (global, everything)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)


chrome : List (Html msg) -> Html msg
chrome children =
    div
        [ css
            [ fontFamilies [ "Bellefair" ]
            , fontSize (px 18)
            , maxWidth (px 960)
            , margin2 (px 0) auto
            ]
        ]
        (global [ everything [ boxSizing borderBox ] ] :: children)
