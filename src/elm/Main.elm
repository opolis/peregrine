port module Main exposing (..)

import BigInt exposing (BigInt)
import Eth
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry exposing (..)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Units exposing (gwei, eth)
import Eth.Utils as EthUtils
import Html exposing (Html)
import Element exposing (..)
import Http
import Ports
import PortsDriver exposing (..)
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
        , view = programView
        , update = update
        , subscriptions = subscriptions
        }



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
    , errors : List String
    }


init : ( Model, Cmd Msg )
init =
    { txSentry = TxSentry.init ( Ports.txOut, Ports.txIn ) TxSentryMsg ethNode.http
    , account = Nothing
    , errors = []
    , dsGroupAddress = Nothing
    , dsGroupInfo = Nothing
    , wizard = Nothing
    , actions = []
    }
        ! [ PortsDriver.localStorageGetItem portsConfig "testkey"
          , Task.perform SetDSGroupAddress (Task.succeed "0x8a6c28475af5b9fd6a2f53170602fd37318a1321")
          ]



-- Ports


portsConfig : Config Msg
portsConfig =
    { output = Ports.output
    , input = Ports.input
    , fail = Fail
    }



-- View
-- view : Model -> Html Msg


programView model =
    layout [] view


view =
    el [] (text "Test")



-- Update
-- , Task.attempt GetProposals (CH.getProposals ethNode dsGroup)


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

        SetDSGroupAddress strAdress ->
            case EthUtils.toAddress strAdress of
                Ok contractAddress ->
                    { model | dsGroupAddress = Just contractAddress }
                        ! [ Task.attempt GetProposals (CH.getProposals ethNode.http contractAddress)
                          , Task.attempt SetDSGroupInfo (DSGroup.getInfo contractAddress |> Eth.call ethNode.http)
                          ]

                Err err ->
                    { model | errors = err :: model.errors } ! []

        SetDSGroupInfo (Ok dsGroupInfo) ->
            { model | dsGroupInfo = Just dsGroupInfo } ! []

        SetDSGroupInfo (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        GetProposals (Ok actions) ->
            { model | actions = actions } ! []

        GetProposals (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        MakeProposal target callData value ->
            case model.dsGroupAddress of
                Nothing ->
                    let
                        _ =
                            Debug.log "no dsgroup address to make proposal"
                    in
                        model ! []

                Just groupAddress ->
                    let
                        target_ =
                            EthUtils.toAddress target

                        callData_ =
                            EthUtils.unsafeToHex callData

                        value_ =
                            BigInt.fromString value
                    in
                        case ( target_, value_ ) of
                            ( Ok targetAddr, Just val ) ->
                                model
                                    ! [ Task.attempt ProposalResponse
                                            (DSGroup.propose groupAddress targetAddr callData_ val
                                                |> Eth.call ethNode.http
                                            )
                                      ]

                            ( _, _ ) ->
                                let
                                    _ =
                                        Debug.log ("Form error for proposal data (targetAddres, calldata, val)" ++ target ++ callData ++ value)
                                in
                                    model ! []

        ProposalResponse (Ok propId) ->
            model ! []

        ProposalResponse (Err err) ->
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
