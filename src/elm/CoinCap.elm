module CoinCap exposing (..)

import Json.Decode as Decode
import Http
import Task exposing (Task)


getPrice : String -> Task Http.Error Float
getPrice ticker =
    Http.get ("https://coincap.io/page/" ++ ticker) (Decode.field "price" Decode.float)
        |> Http.toTask
