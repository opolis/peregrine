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
    , dsGroupBalance : Maybe BigInt
    , actions : List DSGroup.Action
    , descriptions : Descriptions
    , proposals : List Proposal
    , ethUSD : Maybe Float
    , walletBalance : Maybe Float
    , errors : List String
    , pendingTxs : Dict Int TxState
    }


type TxState
    = Default
    | Signing
    | Pending


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
    | WizardMsg Wizard.Msg
      -- UI Msgs
    | SetDSGroupAddress String
    | ToggleWizard
      -- Chain Msgs
    | ConfirmProposal Int
    | SetDSGroupInfo (Result Http.Error DSGroup.GetInfo)
    | SetDSGroupBalance (Result Http.Error BigInt)
    | GetProposals (Result Http.Error (List DSGroup.Action))
    | ProposalTx (Result String Tx)
    | ProposalTxReceipt Address String (Result String TxReceipt)
    | ConfirmTx Int (Result String Tx)
    | ConfirmTxReceipt Int (Result String TxReceipt)
    | PassSplash
      -- Local Storage
    | GetStorageItem String (Maybe String)
    | RefreshStorage
    | UpdateDict String Address (Result Http.Error BigInt)
      -- CoinCap
    | EthPrice (Result Http.Error Float)
      -- Misc Msgs
    | Fail String
    | InitLedger
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
