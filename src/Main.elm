module Main exposing (Model, Msg(..), init, main, update, view)

import Array exposing (Array)
import Array2D
import ArrayUtilities exposing (traverse)
import Browser
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Lazy exposing (..)
import Random
import Shapes exposing (baker, hwss, koksGalaxy, makeShape, pDecathlon, phoenix, pulsar)
import Shared exposing (AutoEvolveState(..), Cell, CellState(..), Grid, Position)
import Styles exposing (..)
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }



-- MODEL


type Preset
    = PDecathlon
    | Pulsar
    | HWSS
    | KoksGalaxy
    | Baker
    | Phoenix


type alias Model =
    { grid : Grid
    , autoEvolveState : AutoEvolveState
    }


blankGrid : Grid
blankGrid =
    initializeSquareGrid 30


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (makeShape ( 9, 11 ) pulsar blankGrid) Off, Cmd.none )



-- UPDATE


type Msg
    = Evolve
    | Flip Position
    | AutoEvolve
    | SetRandomGrid Grid
    | GenerateRandomGrid
    | Clear
    | Make Preset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Evolve ->
            ( { model | grid = transition model.grid }, Cmd.none )

        Flip position ->
            ( { model | grid = flipLifeAtPosition position model.grid }, Cmd.none )

        AutoEvolve ->
            ( { model
                | autoEvolveState =
                    if model.autoEvolveState == On then
                        Off

                    else
                        On
              }
            , Cmd.none
            )

        SetRandomGrid grid ->
            ( { model | grid = grid }, Cmd.none )

        GenerateRandomGrid ->
            ( model, Random.generate SetRandomGrid (randomGrid model.grid) )

        Clear ->
            ( Model blankGrid Off, Cmd.none )

        Make preset ->
            case preset of
                PDecathlon ->
                    ( { model | grid = makeShape ( 11, 14 ) pDecathlon model.grid }, Cmd.none )

                Pulsar ->
                    ( { model | grid = makeShape ( 9, 11 ) pulsar model.grid }, Cmd.none )

                HWSS ->
                    ( { model | grid = makeShape ( 9, 11 ) hwss model.grid }, Cmd.none )

                KoksGalaxy ->
                    ( { model | grid = makeShape ( 10, 11 ) koksGalaxy model.grid }, Cmd.none )

                Baker ->
                    ( { model | grid = makeShape ( 25, 5 ) baker model.grid }, Cmd.none )

                Phoenix ->
                    ( { model | grid = makeShape ( 11, 14 ) phoenix model.grid }, Cmd.none )


initializeSquareGrid : Int -> Grid
initializeSquareGrid n =
    Array2D.initialize n n (\row col -> { life = Dead, position = ( row, col ) })


randomLife : Random.Generator CellState
randomLife =
    Random.uniform Alive [ Dead ]


randomCell : Cell -> Random.Generator Cell
randomCell cell =
    Random.map (\s -> { cell | life = s }) randomLife


randomGrid : Grid -> Random.Generator Grid
randomGrid grid =
    traverse (traverse randomCell) grid.data |> Random.map (\random2DArray -> { grid | data = random2DArray })


flipLifeAtPosition : Position -> Grid -> Grid
flipLifeAtPosition ( x, y ) grid =
    case Array2D.get x y grid of
        Just cell ->
            Array2D.set x y { cell | life = flipLife cell.life } grid

        Nothing ->
            grid


flipLife : CellState -> CellState
flipLife state =
    case state of
        Alive ->
            Dead

        Dead ->
            Alive


transition : Grid -> Grid
transition grid =
    Array2D.map (transitionCell grid) grid


transitionCell : Grid -> Cell -> Cell
transitionCell grid cell =
    let
        count =
            countAdjacent cell.position grid
    in
    case cell.life of
        Alive ->
            if count < 2 then
                { cell | life = Dead }

            else if count < 4 then
                cell

            else
                { cell | life = Dead }

        Dead ->
            if count == 3 then
                { cell | life = Alive }

            else
                cell


countAdjacent : Position -> Grid -> Int
countAdjacent ( x, y ) grid =
    let
        moduloPosition : Position -> Int -> Position
        moduloPosition ( p, q ) d =
            ( modBy d p, modBy d q )

        wrap : Position -> Position
        wrap position =
            moduloPosition position grid.columns

        neighborsWrapped : List Position
        neighborsWrapped =
            List.map wrap
                [ ( x, y - 1 )
                , -- N
                  ( x + 1, y - 1 )
                , -- NE
                  ( x + 1, y )
                , -- E
                  ( x + 1, y + 1 )
                , -- SE
                  ( x, y + 1 )
                , -- S
                  ( x - 1, y + 1 )
                , -- SW
                  ( x - 1, y )
                , -- W
                  ( x - 1, y - 1 )

                -- NW
                ]
    in
    List.map (\( i, j ) -> Array2D.get i j grid) neighborsWrapped
        |> countAlives



-- should never actually be Nothing because of modulo wrapping


countAlives : List (Maybe Cell) -> Int
countAlives ls =
    ls |> List.filterMap identity |> List.filter (\el -> el.life == Alive) |> List.length



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.autoEvolveState of
        Off ->
            Sub.none

        On ->
            Time.every 500 (\_ -> Evolve)



-- VIEW


view : Model -> Html Msg
view model =
    let
        topRightPosition =
            [ top (px 15), right (px 15) ]

        bottomRightPosition =
            [ bottom (px 10), right (px 10) ]

        mediumAndLargeDiv =
            [ padding4 zero (pct 5) (pct 2) (pct 5) ]

        tinyAndSmallDiv =
            [ padding4 zero (pct 4) (pct 2) (pct 4) ]
    in
    div [ css [ displayFlex, flexDirection column, height (pct 100), tinyScreen tinyAndSmallDiv, smallScreen tinyAndSmallDiv, mediumScreen mediumAndLargeDiv, largeScreen mediumAndLargeDiv ] ]
        [ a [ href "https://github.com/deklanw/gameoflife-elm" ] [ img [ src "github-logo.svg", css [ fill theme.white, position absolute, height (px 30), width (px 30), tinyScreen bottomRightPosition, smallScreen bottomRightPosition, mediumScreen bottomRightPosition, largeScreen topRightPosition ] ] [] ]
        , topView
        , bottomView model
        ]


topView : Html Msg
topView =
    let
        titleLower =
            "Conway's Game of Life"

        divLarge =
            [ textAlign left ]

        divTinySmallMedium =
            [ textAlign center ]

        hTiny =
            [ fontSize (px 30) ]

        hSmall =
            [ fontSize (px 50) ]

        hMedium =
            [ fontSize (px 60) ]

        hLarge =
            [ fontSize (px 70) ]
    in
    div [ css [ tinyScreen divTinySmallMedium, smallScreen divTinySmallMedium, mediumScreen divTinySmallMedium, largeScreen divLarge ] ] [ h1 [ css [ siteHeaderFont, margin2 (rem 3.5) zero, tinyScreen hTiny, smallScreen hSmall, mediumScreen hMedium, largeScreen hLarge ] ] [ text titleLower ] ]


bottomView : Model -> Html Msg
bottomView model =
    div
        [ css [ displayFlex, flexDirection column, largeScreen [ flexDirection row ] ] ]
        [ leftPane model
        , rightPane
        ]


leftPane : Model -> Html Msg
leftPane model =
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
    div [ css [ flex (int 3) ] ]
        [ div [ css [ displayFlex, tinyScreen tiny, smallScreen small, mediumScreen medium, largeScreen large ] ] [ myGrid model, buttonGroups model ] ]


buttonGroups : Model -> Html Msg
buttonGroups model =
    let
        buttonGroupMargin =
            margin2 zero (px 30)

        buttonGroupTinyMargin =
            margin2 zero (px 15)

        buttonGroupWithHeading =
            styled div [ displayFlex, alignItems center, flexDirection column, tinyScreen [ buttonGroupTinyMargin ], smallScreen [ buttonGroupMargin ], mediumScreen [ buttonGroupMargin ] ]

        buttonHeading =
            styled h1 [ buttonHeadersFont ]

        tiny =
            [ flexDirection row, alignItems start, marginTop (px 10) ]

        small =
            [ flexDirection row, alignItems start, marginTop (px 15) ]

        medium =
            [ flexDirection row, alignItems start, marginTop (px 20) ]

        large =
            [ flexDirection column, justifyContent spaceBetween, marginTop (px 25), paddingLeft (pct 3) ]
    in
    div [ css [ displayFlex, tinyScreen tiny, smallScreen small, mediumScreen medium, largeScreen large ] ]
        [ buttonGroupWithHeading []
            [ buttonHeading [ css [ largeScreen [ marginTop zero ] ] ] [ text "Controls" ]
            , controlButtons model
            ]
        , buttonGroupWithHeading
            []
            [ buttonHeading []
                [ text "Presets" ]
            , presetButtons
            ]
        ]


presetButtons : Html Msg
presetButtons =
    buttonGroup []
        [ btn
            [ onClick (Make Pulsar) ]
            [ text "PULSAR" ]
        , btn [ onClick (Make PDecathlon) ] [ text "P-DECATHLON" ]
        , btn [ onClick (Make KoksGalaxy) ] [ text "KOK'S GALAXY" ]
        , btn [ onClick (Make HWSS) ] [ text "HW SPACESHIP" ]
        , btn [ onClick (Make Baker) ] [ text "BAKER" ]
        , btn [ onClick (Make Phoenix) ] [ text "PHOENIX 1" ]
        ]


controlButtons : Model -> Html Msg
controlButtons model =
    buttonGroup []
        [ btn [ onClick Evolve ] [ text "EVOLVE" ]
        , btn [ onClick AutoEvolve ]
            [ if model.autoEvolveState == Off then
                span [] [ text "AUTOEVOLVE ", span [ css [ color theme.off ] ] [ text "OFF" ] ]

              else
                span [] [ text "AUTOEVOLVE ", span [ css [ color theme.on ] ] [ text "ON" ] ]
            ]
        , btn [ onClick GenerateRandomGrid ] [ text "RANDOMIZE" ]
        , btn [ onClick Clear ] [ text "CLEAR" ]
        ]


rightPane : Html Msg
rightPane =
    div [ css [ flex (int 2), paragraphBodyFont, lineHeight (rem 1.3), marginTop (pct 5), largeScreen [ marginTop zero ] ] ]
        [ howToUseSection, lawsSection, aboutSection ]


lawsSection : Html Msg
lawsSection =
    let
        forThisDemo =
            "For this demonstration, the edges wrap around like Pacman."
    in
    spacedSection [] [ paragraphHeader [] [ text "Laws" ], lawsList, p [] [ text forThisDemo ] ]


aboutSection : Html Msg
aboutSection =
    let
        history =
            "The Game of Life is a cellular automaton devised by mathematician John Conway. It was popularized by Martin Gardener's Scientific American column in 1970. A cellular automaton is a discrete model consisting of a grid with cells that have state; the grid evolves iteratively -- each cell evolving as a function of the state of its neighboring cells. Cellular automata had been devised earlier by Stanislaw Ulam and John von Neumann during the 40s and 50s in the course of Neumann's work on self-replicating systems."

        interesting =
            "The Game of Life has interesting properties:"
    in
    spacedSection [] [ paragraphHeader [] [ text "About" ], p [] [ text history ], p [] [ text interesting ], interestingProperties ]


howToUseSection : Html Msg
howToUseSection =
    let
        content =
            "Click on EVOLVE a few times and see what happens. Try out a Preset to see known interestings pattern. Click on a Cell to manually turn it On or Off."
    in
    spacedSection [] [ paragraphHeader [ css [ marginTop zero ] ] [ text "How to use" ], p [] [ text content ] ]


interestingProperties : Html Msg
interestingProperties =
    let
        turingComplete =
            "It's Turing-complete. In fact, there are even simpler 1-dimensional cellular automata which are Turing-complete."

        haltingProblem =
            "Given an arbitrary starting pattern and an arbitrary final pattern, there is no general method for determining if the starting pattern will evolve into the final pattern. This is a consequence of the Halting Problem."

        eden =
            "Given any arbitrary pattern of Alive/Dead cells, there does not always exist a prior pattern that will evolve into that final pattern. In other words, there exists configurations, called Garden of Eden configurations, which can't result from evolution."
    in
    ul [ css [ listStyleType square ] ]
        [ liC []
            [ text turingComplete ]
        , liC [] [ text haltingProblem ]
        , liC [] [ text eden ]
        ]


lawsList : Html Msg
lawsList =
    ul [ css [ listStyleType square ] ]
        [ liC [] [ text "If an Alive cell has less than 2 neighbors it dies, as if by underpopulation." ]
        , liC [] [ text "If an Alive cell has 2 or 3 neighbors it stays alive." ]
        , liC [] [ text "If an Alive cell has more than 3 neighbors it dies, as if by overpopulation." ]
        , liC [] [ text "If a Dead cell has exactly 3 neighbors it comes alive, as if by reproduction, otherwise it stays dead." ]
        ]


myGrid : Model -> Html Msg
myGrid { grid } =
    let
        tinyAndSmallSize =
            [ width (vw 100), height (vw 100) ]

        mediumSize =
            [ width (px 700), height (px 700) ]

        largeSize =
            [ width (px 600), height (px 600) ]
    in
    div [ css [ displayFlex, flexDirection column, tinyScreen tinyAndSmallSize, smallScreen tinyAndSmallSize, mediumScreen mediumSize, largeScreen largeSize ] ]
        (Array.toList (Array.map (lazy makeRow) grid.data))


makeRow : Array Cell -> Html Msg
makeRow arr =
    div [ css [ displayFlex, flex (int 1) ] ] (Array.toList (Array.map displayCell arr))


displayCell : Cell -> Html Msg
displayCell { life, position } =
    let
        cellColor : CellState -> Color
        cellColor l =
            case l of
                Alive ->
                    theme.aliveColor

                Dead ->
                    theme.deadColor
    in
    div [ onClick (Flip position), css [ flex (int 1), backgroundColor (cellColor life), margin (px 0) ] ]
        []
