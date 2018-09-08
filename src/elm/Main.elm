port module Main exposing (..)

import Eth
import Eth.Net as Net exposing (NetworkId(..))
import Eth.Types exposing (..)
import Eth.Sentry.Tx as TxSentry exposing (..)
import Eth.Sentry.Wallet as WalletSentry exposing (WalletSentry)
import Eth.Units exposing (gwei, eth)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Value)
import Ports
import PortsDriver exposing (..)
import Process
import Task


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { txSentry : TxSentry Msg
    , account : Maybe Address
    , node : EthNode
    , blockNumber : Maybe Int
    , txHash : Maybe TxHash
    , tx : Maybe Tx
    , txReceipt : Maybe TxReceipt
    , blockDepth : String
    , errors : List String
    }


type alias EthNode =
    { http : HttpProvider
    , ws : WebsocketProvider
    }


portsConfig : Config Msg
portsConfig =
    { output = Ports.output
    , input = Ports.input
    , fail = Fail
    }


node : EthNode
node =
    { http = "http://127.0.0.1:8545"
    , ws = ""
    }


init : ( Model, Cmd Msg )
init =
    { txSentry = TxSentry.init ( Ports.txOut, Ports.txIn ) TxSentryMsg node.http
    , account = Nothing
    , node = node
    , blockNumber = Nothing
    , txHash = Nothing
    , tx = Nothing
    , txReceipt = Nothing
    , blockDepth = ""
    , errors = []
    }
        ! [ Task.attempt PollBlock (Eth.getBlockNumber node.http)
          , PortsDriver.localStorageGetItem portsConfig "testkey"
          ]



-- View


view : Model -> Html Msg
view model =
    div []
        [ div []
            (List.map viewThing
                [ ( "Current Block", toString model.blockNumber )
                , ( "--------------------", "" )
                , ( "TxHash", toString model.txHash )
                , ( "--------------------", "" )
                , ( "Tx", toString model.tx )
                , ( "--------------------", "" )
                , ( "TxReceipt", toString model.txReceipt )
                , ( "--------------------", "" )
                , ( "BlockDepth", toString model.blockDepth )
                ]
            )
        , button [ onClick InitTx ] [ text "Send Tx" ]
        , div [] (List.map (\e -> div [] [ text e ]) model.errors)
        ]


viewThing : ( String, String ) -> Html Msg
viewThing ( name, val ) =
    div []
        [ div [] [ text name ]
        , div [] [ text val ]
        ]



-- Update


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
    | PollBlock (Result Http.Error Int)
    | InitTx
    | WatchTxHash (Result String TxHash)
    | WatchTx (Result String Tx)
    | WatchTxReceipt (Result String TxReceipt)
    | TrackTx TxTracker
    | ReceiveStorageItem String (Maybe String)
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

        PollBlock (Ok blockNumber) ->
            { model | blockNumber = Just blockNumber }
                ! [ Task.attempt PollBlock <|
                        Task.andThen (\_ -> Eth.getBlockNumber model.node.http) (Process.sleep 1000)
                  ]

        PollBlock (Err error) ->
            model ! []

        InitTx ->
            let
                txParams =
                    { to = model.account
                    , from = model.account
                    , gas = Nothing
                    , gasPrice = Just <| gwei 4
                    , value = Just <| eth 1
                    , data = Nothing
                    , nonce = Nothing
                    }

                ( newSentry, sentryCmd ) =
                    TxSentry.customSend
                        model.txSentry
                        { onSign = Just WatchTxHash
                        , onBroadcast = Just WatchTx
                        , onMined = Just ( WatchTxReceipt, Just { confirmations = 3, toMsg = TrackTx } )
                        }
                        txParams
            in
                { model | txSentry = newSentry } ! [ sentryCmd ]

        WatchTxHash (Ok txHash) ->
            { model | txHash = Just txHash } ! []

        WatchTxHash (Err err) ->
            { model | errors = ("Error Retrieving TxHash: " ++ toString err) :: model.errors } ! []

        WatchTx (Ok tx) ->
            { model | tx = Just tx } ! []

        WatchTx (Err err) ->
            { model | errors = ("Error Retrieving Tx: " ++ toString err) :: model.errors } ! []

        WatchTxReceipt (Ok txReceipt) ->
            { model | txReceipt = Just txReceipt } ! []

        WatchTxReceipt (Err err) ->
            { model | errors = ("Error Retrieving TxReceipt: " ++ toString err) :: model.errors } ! []

        TrackTx blockDepth ->
            { model | blockDepth = toString blockDepth } ! []

        ReceiveStorageItem key mValue ->
            let
                _ =
                    Debug.log "localStorage value" mValue
            in
                model ! []

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
