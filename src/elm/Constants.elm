module Constants exposing (..)

import Eth.Types exposing (..)
import Eth.Utils as EthUtils
import Types exposing (EthNode)


contractKey : String
contractKey =
    "peregrine.contract"


dsGroup : Address
dsGroup =
    EthUtils.unsafeToAddress "0x8a6c28475af5b9fd6a2f53170602fd37318a1321"


ethNode : EthNode
ethNode =
    { http = "https://rinkeby.infura.io/"
    , ws = "wss://rinkeby.infura.io/ws"
    }
