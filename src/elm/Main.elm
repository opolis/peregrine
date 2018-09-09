port module Main exposing (..)

import BigInt exposing (BigInt)
import CoinCap exposing (getPrice)
import Dict
import Eth
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry
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
import Constants exposing (contractKey, dsGroup, ethNode)
import Result
import Types exposing (..)
import Json.Decode exposing (decodeString)
import View.Main as MainView
import View.Wizard as Wizard
import Time
import Process


-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    { txSentry = TxSentry.init ( Ports.txOut, Ports.txIn ) TxSentryMsg ethNode.http
    , account = Nothing
    , errors = []
    , dsGroupAddress = Nothing
    , dsGroupInfo = Nothing
    , wizard = Nothing
    , proposals = []
    , actions = []
    , screen = ProposalList
    , ethUSD = Nothing
    , walletBalance = Nothing
    , descriptions = Dict.empty
    }
        ! [ PortsDriver.localStorageGetItem portsConfig contractKey
          , Task.attempt EthPrice <| getPrice "ETH"
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
    layout [] (MainView.view model)



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TxSentryMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    TxSentry.update subMsg model.txSentry
            in
                ( { model | txSentry = subModel }, subCmd )

        WizardMsg (Wizard.Propose userAddress toAddress value hexData desc) ->
            case model.dsGroupAddress of
                Just groupAddress ->
                    let
                        ( newTxSentry, cmd ) =
                            (DSGroup.propose groupAddress toAddress hexData value)
                                |> Eth.toSend
                                |> (\s -> { s | to = Just userAddress })
                                |> TxSentry.sendWithReceipt ProposalTx ProposalTxReceipt model.txSentry
                    in
                        model ! []

                _ ->
                    model ! []

        WizardMsg subMsg ->
            case model.wizard of
                Just wizard ->
                    let
                        ( subModel, subCmd ) =
                            Wizard.update subMsg wizard
                    in
                        ( { model | wizard = Just subModel }
                        , Cmd.map WizardMsg subCmd
                        )

                Nothing ->
                    model ! []

        WalletStatus walletSentry ->
            { model
                | account = walletSentry.account
            }
                ! []

        GetStorageItem key mValue ->
            let
                _ =
                    Debug.log "localStorage key" key

                _ =
                    Debug.log "localStorage value" mValue
            in
                case mValue of
                    Nothing ->
                        if (EthUtils.isAddress key) then
                            { model | descriptions = Dict.empty, proposals = [], actions = [], dsGroupInfo = Nothing } ! []
                        else
                            model ! []

                    Just value ->
                        if key == contractKey then
                            model ! [ Task.perform SetDSGroupAddress <| Task.succeed value ]
                        else if (EthUtils.isAddress key) then
                            case model.dsGroupAddress of
                                Nothing ->
                                    model ! []

                                Just addr ->
                                    -- decode descriptions stored locally before fetching actions from chain
                                    case (decodeString decodeDescriptions value) of
                                        Ok descriptions ->
                                            { model | descriptions = descriptions }
                                                ! [ Task.attempt GetProposals (CH.getProposals ethNode.http addr) ]

                                        Err err ->
                                            { model | errors = err :: model.errors } ! []
                        else
                            model ! []

        SetDSGroupAddress strAddress ->
            case EthUtils.toAddress strAddress of
                Ok contractAddress ->
                    { model | dsGroupAddress = Just contractAddress }
                        ! [ Task.attempt SetDSGroupInfo (DSGroup.getInfo contractAddress |> Eth.call ethNode.http)
                          , PortsDriver.localStorageSetItem portsConfig contractKey (EthUtils.addressToString contractAddress)
                          , PortsDriver.localStorageGetItem portsConfig <| EthUtils.addressToString contractAddress
                          ]

                Err err ->
                    model ! []

        SetDSGroupInfo (Ok dsGroupInfo) ->
            { model | dsGroupInfo = Just dsGroupInfo } ! []

        SetDSGroupInfo (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        GetProposals (Ok actions) ->
            { model | actions = actions, proposals = buildProposals model.descriptions actions } ! []

        GetProposals (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        ToggleWizard ->
            case model.wizard of
                Nothing ->
                    { model | wizard = Just Wizard.init } ! []

                Just _ ->
                    { model | wizard = Nothing } ! []

        ProposalTx (Ok propId) ->
            model ! []

        ProposalTx (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        ProposalTxReceipt (Ok txReceipt) ->
            { model | wizard = Nothing } ! []

        ProposalTxReceipt (Err err) ->
            { model | errors = toString err :: model.errors } ! []

        EthPrice (Ok price) ->
            { model | ethUSD = Just price }
                ! [ Task.attempt EthPrice
                        (Process.sleep (10 * Time.second)
                            |> Task.andThen ((\_ -> getPrice "ETH"))
                        )
                  ]

        EthPrice (Err err) ->
            { model | ethUSD = Nothing, errors = (toString err) :: model.errors } ! []

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
            [ PortsDriver.receiveLocalStorageItem GetStorageItem ]
        , TxSentry.listen model.txSentry
        ]
