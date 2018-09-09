port module Ports exposing (..)

import Json.Decode exposing (Value)


port output : Value -> Cmd msg


port input : (Value -> msg) -> Sub msg


port walletSentry : (Value -> msg) -> Sub msg


port txOut : Value -> Cmd msg


port txIn : (Value -> msg) -> Sub msg


port initLedger : Value -> Cmd msg
