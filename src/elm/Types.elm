module Types exposing (..)

import Contract.DSGroup as DSGroup exposing (Action)
import Json.Decode exposing (Decoder, decodeString, dict, string)
import Dict exposing (Dict)
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry exposing (TxSentry)
import Http
import BigInt exposing (BigInt)
import Eth.Sentry.Wallet exposing (WalletSentry)


-- Screens


type ProposalWizard
    = ChooseProposalType
    | EthSend
    | ContractSend



-- Model


type alias Model =
    { txSentry : TxSentry Msg
    , account : Maybe Address
    , wizard : Maybe ProposalWizard
    , dsGroupAddress : Maybe Address
    , dsGroupInfo : Maybe DSGroup.GetInfo
    , actions : List DSGroup.Action
    , proposals : List Proposal
    , errors : List String
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
    | ReceiveStorageItem String (Maybe String)
      -- UI Msgs
    | SetDSGroupAddress String
    | MakeProposal String String String
      -- Chain Msgs
    | SetDSGroupInfo (Result Http.Error DSGroup.GetInfo)
    | GetProposals (Result Http.Error (List DSGroup.Action))
    | ProposalResponse (Result Http.Error BigInt)
      -- Misc Msgs
    | Fail String
    | NoOp


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
