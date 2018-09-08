port module Main exposing (..)

import Eth
import Eth.Net as Net exposing (NetworkId(..))
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry exposing (..)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Units exposing (gwei, eth)
import Eth.Utils as EthUtils
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Value)
import Ports
import PortsDriver exposing (..)
import Process
import Task
import Contract.DSGroup as DSGroup
import Contract.ERC20
import Contract.Helpers as CH
import Constants exposing (ethNode, dsGroup)


-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Screens


type ProposalWizard
    = EthSend
    | ContractSend



-- Model


type alias Model =
    { txSentry : TxSentry Msg
    , account : Maybe Address
    , errors : List String
    , dsGroup : Maybe Address
    , wizard : Maybe ProposalWizard
    , actions : List DSGroup.Action
    }


init : ( Model, Cmd Msg )
init =
    { txSentry = TxSentry.init ( Ports.txOut, Ports.txIn ) TxSentryMsg ethNode.http
    , account = Nothing
    , errors = []
    , dsGroup = Nothing
    , wizard = Nothing
    , actions = []
    }
        ! [ PortsDriver.localStorageGetItem portsConfig "testkey"
          ]



-- Ports


portsConfig : Config Msg
portsConfig =
    { output = Ports.output
    , input = Ports.input
    , fail = Fail
    }



-- View


view : Model -> Html Msg
view model =
    div [] []



-- Update
-- , Task.attempt GetProposals (CH.getProposals ethNode dsGroup)


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
    | ReceiveStorageItem String (Maybe String)
      -- UI Msgs
    | SetDSGroup String
      -- Chain Msgs
    | GetProposals (Result Http.Error (List DSGroup.Action))
      -- Misc Msgs
    | Fail String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TxSentryMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    TxSentry.update subMsg model.txSentry
            in
                ( { model | txSentry = subModel }, subCmd )

        WalletStatus walletSentry ->
            { model
                | account = walletSentry.account
            }
                ! []

        ReceiveStorageItem key mValue ->
            let
                _ =
                    Debug.log "localStorage value" mValue
            in
                model ! []

        SetDSGroup strAdress ->
            case EthUtils.toAddress strAdress of
                Ok contractAddress ->
                    { model | dsGroup = Just contractAddress }
                        ! [ Task.attempt GetProposals (CH.getProposals ethNode.http contractAddress) ]

                Err err ->
                    model ! []

        GetProposals (Ok actions) ->
            { model | actions = actions } ! []

        GetProposals (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        Fail str ->
            let
                _ =
                    Debug.log str
            in
                model ! []

        NoOp ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.walletSentry (WalletSentry.decodeToMsg Fail WalletStatus)
        , PortsDriver.subscriptions portsConfig
            [ PortsDriver.receiveLocalStorageItem ReceiveStorageItem ]
        , TxSentry.listen model.txSentry
        ]
