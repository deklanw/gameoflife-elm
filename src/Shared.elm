module Shared exposing (AutoEvolveState(..), Cell, CellState(..), Grid, Position)

import Array2D exposing (Array2D)


type alias Position =
    ( Int, Int )


type CellState
    = Alive
    | Dead


type alias Cell =
    { life : CellState, position : Position }


type alias Grid =
    Array2D Cell


type AutoEvolveState
    = Off
    | On
