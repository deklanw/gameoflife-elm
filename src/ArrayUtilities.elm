module ArrayUtilities exposing (traverse)

import Array exposing (Array)
import Random


sequence : Array (Random.Generator a) -> Random.Generator (Array a)
sequence =
    Array.foldl (Random.map2 Array.push) (Random.constant (Array.fromList []))


traverse : (a -> Random.Generator b) -> Array a -> Random.Generator (Array b)
traverse f =
    sequence << Array.map f
