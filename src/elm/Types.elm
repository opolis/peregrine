module Types exposing (..)

import Contract.DSGroup as DSGroup exposing (Action)
import Json.Decode exposing (Decoder, decodeString, dict, string)
import Dict exposing (Dict)
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry exposing (TxSentry)
import Http
import BigInt exposing (BigInt)
import Eth.Sentry.Wallet exposing (WalletSentry)
import View.Wizard as Wizard


-- Model


type alias Model =
    { txSentry : TxSentry Msg
    , account : Maybe Address
    , wizard : Maybe Wizard.Model
    , screen : Screen
    , dsGroupAddress : Maybe Address
    , dsGroupInfo : Maybe DSGroup.GetInfo
    , actions : List DSGroup.Action
    , descriptions : Descriptions
    , proposals : List Proposal
    , ethUSD : Maybe Float
    , walletBalance : Maybe Float
    , errors : List String
    }


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
    | WizardMsg Wizard.Msg
      -- UI Msgs
    | SetDSGroupAddress String
    | ToggleWizard
      -- Chain Msgs
    | SetDSGroupInfo (Result Http.Error DSGroup.GetInfo)
    | GetProposals (Result Http.Error (List DSGroup.Action))
    | ProposalTx (Result String Tx)
    | ProposalTxReceipt (Result String TxReceipt)
      -- Local Storage
    | GetStorageItem String (Maybe String)
      -- CoinCap
    | EthPrice (Result Http.Error Float)
      -- Misc Msgs
    | Fail String
    | NoOp



-- Screens


type Screen
    = Splash
    | ProposalList


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
            , id = index + 1
            , description =
                case (Dict.get (toString index) descriptions) of
                    Nothing ->
                        Debug.crash "missing proposal id from dict"

                    Just description ->
                        description
            }
        )
