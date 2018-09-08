module Types exposing (..)

import Eth.Types exposing (..)


type alias EthNode =
    { http : HttpProvider
    , ws : WebsocketProvider
    }
