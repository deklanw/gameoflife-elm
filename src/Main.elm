module Main exposing (Model, Msg(..), init, main, update, view)

import Array exposing (Array)
import Array2D
import ArrayUtilities exposing (traverse)
import Browser
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, css, href, src)
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
    styledSiteContainer []
        [ a [ href "https://github.com/deklanw/gameoflife-elm" ] [ styledGitHubLogo [ src "github-logo.svg", alt "GitHub logo" ] [] ]
        , topView
        , bottomView model
        ]


topView : Html Msg
topView =
    let
        titleLower =
            "Conway's Game of Life"
    in
    styledTopView [] [ siteHeader [] [ text titleLower ] ]


bottomView : Model -> Html Msg
bottomView model =
    styledBottomView
        []
        [ leftPane model
        , rightPane
        ]


leftPane : Model -> Html Msg
leftPane model =
    div [ css [ flex (int 3) ] ]
        [ styledLeftPane [] [ myGrid model, buttonGroups model ] ]


buttonGroups : Model -> Html Msg
buttonGroups model =
    styledButtonGroupContainer []
        [ styledButtonGroupWithHeading []
            [ styledButtonHeading [ css [ largeScreen [ marginTop zero ] ] ] [ text "Controls" ]
            , controlButtons model
            ]
        , styledButtonGroupWithHeading
            []
            [ styledButtonHeading []
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
    styledRightPane []
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
    squareList []
        [ styledLi []
            [ text turingComplete ]
        , styledLi [] [ text haltingProblem ]
        , styledLi [] [ text eden ]
        ]


lawsList : Html Msg
lawsList =
    squareList []
        [ styledLi [] [ text "If an Alive cell has less than 2 neighbors it dies, as if by underpopulation." ]
        , styledLi [] [ text "If an Alive cell has 2 or 3 neighbors it stays alive." ]
        , styledLi [] [ text "If an Alive cell has more than 3 neighbors it dies, as if by overpopulation." ]
        , styledLi [] [ text "If a Dead cell has exactly 3 neighbors it comes alive, as if by reproduction, otherwise it stays dead." ]
        ]


myGrid : Model -> Html Msg
myGrid { grid } =
    styledMyGrid []
        (Array.toList (Array.map (lazy makeRow) grid.data))


makeRow : Array Cell -> Html Msg
makeRow arr =
    styledRow [] (Array.toList (Array.map displayCell arr))


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
    styledCell [ onClick (Flip position), css [ backgroundColor (cellColor life) ] ]
        []
