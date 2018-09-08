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
import Process
import Task
import Contract.DSGroup
import Contract.ERC20


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
    , errors : List String
    }


type alias EthNode =
    { http : HttpProvider
    , ws : WebsocketProvider
    }


node : EthNode
node =
    { http = "https://rinkeby.infura.io/"
    , ws = "wss://rinkeby.infura.io/ws"
    }


init : ( Model, Cmd Msg )
init =
    { txSentry = TxSentry.init ( txOut, txIn ) TxSentryMsg node.http
    , account = Nothing
    , errors = []
    }
        ! []



-- View


view : Model -> Html Msg
view model =
    div [] []



-- Update


type Msg
    = TxSentryMsg TxSentry.Msg
    | WalletStatus WalletSentry
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
        [ walletSentry (WalletSentry.decodeToMsg Fail WalletStatus)
        , TxSentry.listen model.txSentry
        ]



-- Ports


port walletSentry : (Value -> msg) -> Sub msg


port txOut : Value -> Cmd msg


port txIn : (Value -> msg) -> Sub msg
