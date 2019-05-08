module Styles exposing (btn, buttonGroup, buttonHeadersFont, largeScreen, liC, mediumScreen, paragraphBodyFont, paragraphHeader, paragraphHeadersFont, siteHeaderFont, smallScreen, spacedSection, theme, tinyScreen)

import Css exposing (..)
import Css.Media exposing (maxWidth, minWidth, only, screen, withMedia)
import Html.Styled exposing (..)


largeScreen : List Style -> Style
largeScreen =
    withMedia [ only screen [ minWidth (px 1650) ] ]


mediumScreen : List Style -> Style
mediumScreen =
    withMedia [ only screen [ minWidth (px 801), maxWidth (px 1649) ] ]


smallScreen : List Style -> Style
smallScreen =
    withMedia [ only screen [ minWidth (px 421), maxWidth (px 800) ] ]


tinyScreen : List Style -> Style
tinyScreen =
    withMedia [ only screen [ maxWidth (px 420) ] ]


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button [ buttonFont, height (px 45), backgroundColor transparent, border zero, cursor pointer ]


liC : List (Attribute msg) -> List (Html msg) -> Html msg
liC =
    styled li [ marginBottom (px 5) ]


spacedSection : List (Attribute msg) -> List (Html msg) -> Html msg
spacedSection =
    styled section [ marginBottom (px 5) ]


paragraphHeader : List (Attribute msg) -> List (Html msg) -> Html msg
paragraphHeader =
    styled h1 [ paragraphHeadersFont ]


buttonGroup : List (Attribute msg) -> List (Html msg) -> Html msg
buttonGroup =
    let
        tiny =
            width (px 150)

        small =
            width (px 175)

        medium =
            width (px 200)

        large =
            width (px 200)
    in
    styled div [ displayFlex, flexDirection column, border3 (px 2) solid theme.deadColor, tinyScreen [ tiny ], smallScreen [ small ], mediumScreen [ medium ], largeScreen [ large ] ]


theme =
    { aliveColor = hex "#00FF90"
    , deadColor = hex "#2C40C1"
    , white = hex "#fff"
    , offwhite = hex "#F3F3F3"
    , black = hex "#000"
    , on = hex "#00FF00"
    , off = hex "#FF0000"
    , titleColor = hex "#FFF"
    }


fontMono : Style
fontMono =
    fontFamilies [ "IBM Plex Mono" ]


paragraphHeadersFont : Style
paragraphHeadersFont =
    Css.batch
        [ fontMono
        , fontSize (px 30)
        , fontWeight bold
        , color theme.white
        , tinyScreen [ fontSize (px 18) ]
        , smallScreen [ fontSize (px 20) ]
        , mediumScreen [ fontSize (px 24) ]
        , largeScreen [ fontSize (px 30) ]
        ]


paragraphBodyFont : Style
paragraphBodyFont =
    Css.batch
        [ fontMono
        , fontWeight normal
        , color theme.offwhite
        , tinyScreen [ fontSize (px 12) ]
        , smallScreen [ fontSize (px 13) ]
        , mediumScreen [ fontSize (px 14) ]
        , largeScreen [ fontSize (px 16) ]
        ]


buttonFont : Style
buttonFont =
    Css.batch
        [ fontMono
        , fontWeight normal
        , color theme.white
        , border3 (px 2) solid theme.deadColor
        , tinyScreen [ fontSize (px 12) ]
        , smallScreen [ fontSize (px 14) ]
        , mediumScreen [ fontSize (px 15) ]
        , largeScreen [ fontSize (px 15) ]
        ]


buttonHeadersFont : Style
buttonHeadersFont =
    Css.batch
        [ fontMono
        , fontWeight bold
        , color theme.white
        , tinyScreen [ fontSize (px 14) ]
        , smallScreen [ fontSize (px 16) ]
        , mediumScreen [ fontSize (px 18) ]
        , largeScreen [ fontSize (px 20) ]
        ]


siteHeaderFont : Style
siteHeaderFont =
    Css.batch
        [ fontFamilies [ "O4B" ]
        , fontSize (vw 4)
        , color theme.titleColor
        ]
