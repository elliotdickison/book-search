module View.Input exposing (input)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)


input : List (Attribute a) -> List (Html a) -> Html a
input attributes children =
    Html.Styled.input
        ((css
            [ fontFamilies [ "inherit" ]
            , fontSize inherit
            , borderWidth4 (px 0) (px 0) (px 1) (px 0)
            , outline none
            ]
         )
            :: attributes
        )
        children
