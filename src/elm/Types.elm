module Types exposing (..)

import Contract.DSGroup exposing (Action)
import Json.Decode exposing (Decoder, decodeString, dict, string)
import Dict exposing (Dict)
import Eth.Types exposing (..)


type alias EthNode =
    { http : HttpProvider
    , ws : WebsocketProvider
    }


type alias Proposal =
    { id : Int
    , description : String
    , action : Action
    }


type alias Descriptions =
    Dict String String


decodeDescriptions : Decoder Descriptions
decodeDescriptions =
    dict string


buildProposals : Descriptions -> List Action -> List Proposal
buildProposals descriptions =
    List.indexedMap
        (\index action ->
            { action = action
            , id = index
            , description =
                case (Dict.get (toString index) descriptions) of
                    Nothing ->
                        Debug.crash "missing proposal id from dict"

                    Just description ->
                        description
            }
        )
