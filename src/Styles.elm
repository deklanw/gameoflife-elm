module Styles exposing (btn, buttonFont, buttonGroup, buttonHeadersFont, fontMono, largeScreen, mediumScreen, paragraphBodyFont, paragraphHeader, paragraphHeadersFont, siteHeader, siteHeaderFont, smallScreen, spacedSection, squareList, styledBottomView, styledButtonGroupContainer, styledButtonGroupWithHeading, styledButtonHeading, styledCell, styledGitHubLogo, styledLeftPane, styledLi, styledMyGrid, styledRightPane, styledRow, styledSiteContainer, styledTopView, theme, tinyScreen)

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


styledLi : List (Attribute msg) -> List (Html msg) -> Html msg
styledLi =
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


styledBottomView =
    let
        fRow =
            flexDirection row

        fColumn =
            flexDirection column
    in
    styled div [ displayFlex, fColumn, largeScreen [ fRow ] ]


styledButtonGroupContainer =
    let
        tiny =
            [ flexDirection row, alignItems start, marginTop (px 10) ]

        small =
            [ flexDirection row, alignItems start, marginTop (px 15) ]

        medium =
            [ flexDirection row, alignItems start, marginTop (px 20) ]

        large =
            [ flexDirection column, justifyContent spaceBetween, paddingLeft (px 25) ]
    in
    styled div [ displayFlex, tinyScreen tiny, smallScreen small, mediumScreen medium, largeScreen large ]


styledLeftPane =
    let
        tiny =
            [ flexDirection column, alignItems center ]

        small =
            [ flexDirection column, alignItems center ]

        medium =
            [ flexDirection column, alignItems center ]

        large =
            [ flexDirection row ]
    in
    styled div [ displayFlex, tinyScreen tiny, smallScreen small, mediumScreen medium, largeScreen large ]


styledTopView =
    let
        divLarge =
            [ textAlign left ]

        divTinySmallMedium =
            [ textAlign center ]
    in
    styled div [ tinyScreen divTinySmallMedium, smallScreen divTinySmallMedium, mediumScreen divTinySmallMedium, largeScreen divLarge ]


styledButtonGroupWithHeading =
    let
        buttonGroupMargin =
            margin2 zero (px 30)

        buttonGroupTinyMargin =
            margin2 zero (px 15)
    in
    styled div [ displayFlex, alignItems center, flexDirection column, tinyScreen [ buttonGroupTinyMargin ], smallScreen [ buttonGroupMargin ], mediumScreen [ buttonGroupMargin ] ]


styledRightPane =
    styled div [ flex (int 2), paragraphBodyFont, lineHeight (rem 1.3), marginTop (pct 5), largeScreen [ marginTop zero ] ]


siteHeader =
    let
        hTiny =
            [ fontSize (px 28) ]

        hSmall =
            [ fontSize (px 35) ]

        hMedium =
            [ fontSize (px 50) ]

        hLarge =
            [ fontSize (px 65) ]
    in
    styled h1
        [ margin2 (rem 3.5) zero
        , siteHeaderFont
        , tinyScreen hTiny
        , smallScreen hSmall
        , mediumScreen hMedium
        , largeScreen hLarge
        ]


siteHeaderFont : Style
siteHeaderFont =
    Css.batch
        [ fontFamilies [ "TitleBitmap", "monospace" ]
        , fontSize (vw 4)
        , color theme.titleColor
        ]


styledMyGrid =
    let
        tinyAndSmallSize =
            [ width (vw 100), height (vw 100) ]

        mediumSize =
            [ width (px 700), height (px 700) ]

        largeSize =
            [ width (px 600), height (px 600) ]
    in
    styled div [ displayFlex, flexDirection column, tinyScreen tinyAndSmallSize, smallScreen tinyAndSmallSize, mediumScreen mediumSize, largeScreen largeSize ]


styledGitHubLogo =
    let
        topRightPosition =
            [ top (px 15), right (px 15) ]

        bottomRightPosition =
            [ bottom (px 10), right (px 10) ]
    in
    styled img [ fill theme.white, position absolute, height (px 30), width (px 30), tinyScreen bottomRightPosition, smallScreen bottomRightPosition, mediumScreen bottomRightPosition, largeScreen topRightPosition ]


styledSiteContainer =
    let
        mediumAndLargeDiv =
            [ padding4 zero (pct 5) (pct 2) (pct 5) ]

        tinyAndSmallDiv =
            [ padding4 zero (pct 4) (pct 2) (pct 4) ]
    in
    styled div [ displayFlex, flexDirection column, height (pct 100), tinyScreen tinyAndSmallDiv, smallScreen tinyAndSmallDiv, mediumScreen mediumAndLargeDiv, largeScreen mediumAndLargeDiv ]


styledRow =
    styled div [ displayFlex, flex (int 1) ]


styledButtonHeading =
    styled h1 [ buttonHeadersFont ]


styledCell =
    styled div [ flex (int 1), margin (px 0) ]


squareList =
    styled ul [ listStyleType square ]
