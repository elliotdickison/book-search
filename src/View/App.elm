module View.App exposing (chrome)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)


nav : Html msg
nav =
    div
        [ css
            [ displayFlex
            , flexDirection row
            , flexWrap wrap
            , alignItems center
            , justifyContent center
            ]
        ]
        [ div [] [ text "To read" ]
        , div [] [ text "Reading now" ]
        , div [] [ text "Have read" ]
        ]


chrome : List (Html msg) -> Html msg
chrome children =
    div [ css [ fontFamilies [ "Bellefair" ], fontSize (px 18) ] ]
        [ nav
        , div [] children
        ]
