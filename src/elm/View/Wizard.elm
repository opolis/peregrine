module View.Wizard exposing (..)

import Element exposing (..)
import Element.Input as Input
import Element.Background as BG
import View.Helper exposing (..)
import Html
import Html.Events as Html
import Html.Attributes as Html
import Color
import Element.Font as Font
import Eth.Utils as EthUtils
import Eth.Types exposing (Address)
import BigInt exposing (BigInt)


type alias Model =
    { step : Step
    , toAddress : Maybe Address
    , valAmount : Maybe BigInt
    }


init : Model
init =
    { step = Choose
    , toAddress = Nothing
    , valAmount = Nothing
    }


type Step
    = Choose
    | Eth EthStep
    | Contract ContractStep


type EthStep
    = EthChooseAddress
    | EthChooseAmount
    | EthDescription
    | EthConfirm


type ContractStep
    = ContractChoice
    | FunctionChoice
    | ContractDescription
    | ContractConfirm


view : Model -> Element Msg
view model =
    column [ BG.image "static/img/background.svg", height fill ]
        [ case model.step of
            Choose ->
                viewChoose

            Eth ethStep ->
                viewEth model ethStep

            Contract step ->
                none
        ]


viewChoose : Element Msg
viewChoose =
    column []
        [ column [ Font.color Color.white, nunito, centerY, height shrink, spacing 60 ]
            [ el [ centerX ] (text "What would you like to do?")
            , row [ spacing 50 ]
                [ buttonHelper (Eth EthChooseAddress) "Send Eth"
                , buttonHelper (Contract ContractChoice) "Interact With Contract"
                ]
            ]
        ]


viewEth : Model -> EthStep -> Element Msg
viewEth model ethStep =
    let
        addressStr =
            Maybe.map EthUtils.addressToString model.toAddress
                |> Maybe.withDefault "Error parsing address"
    in
        case ethStep of
            EthChooseAddress ->
                column []
                    [ column [ centerY, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white, centerX ]
                            [ el [ centerX, nunito ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 14 ] (text "Step 1 of 4")
                            ]
                        , el [ Font.color Color.white, nunito, centerX, paddingTop 40 ] (text "Where would you like to send Eth?")
                        , inputHelper SetToAddress "Multi-sig wallet Address:"
                        , row [ spacing 50 ]
                            [ buttonHelper (Choose) "Back"
                            , buttonHelper (Eth EthChooseAmount) "Next"
                            ]
                        ]
                    ]

            EthChooseAmount ->
                column []
                    [ column [ centerY, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white, nunito ]
                            [ el [ centerX ] (text "Send Eth")
                            , el [ centerX ] (text "Step 2 of 4")
                            ]
                        , el [ Font.color Color.white, nunito, centerX ] (text "How much ether would you like to send?")
                        , row [ Font.color Color.white, nunito ] [ el [ centerX ] (text "to: "), el [ centerX ] (text addressStr) ]
                        , inputHelper SetAmount "Multi-sig wallet Address:"
                        , row [ spacing 50 ]
                            [ buttonHelper (Eth EthChooseAddress) "Back"
                            , buttonHelper (Eth EthDescription) "Next"
                            ]
                        ]
                    ]

            EthDescription ->
                column []
                    [ column [ centerY, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white, nunito ]
                            [ el [ centerX ] (text "Send Eth")
                            , el [ centerX ] (text "Step 3 of 4")
                            ]
                        , el [ Font.color Color.white, nunito, centerX ] (text "Where would you like to send Eth?")

                        -- , addressInput
                        , row [ spacing 50 ]
                            [ buttonHelper (Eth EthChooseAmount) "Back"
                            , buttonHelper (Eth EthConfirm) "Next"
                            ]
                        ]
                    ]

            EthConfirm ->
                column []
                    [ column [ centerY, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white, nunito, centerX ]
                            [ el [ centerX ] (text "Send Eth")
                            , el [ centerX ] (text "Step 4 of 4")
                            ]
                        , el [ Font.color Color.white, nunito, centerX ] (text "Where would you like to send Eth?")

                        -- , addressInput
                        , row [ spacing 50 ]
                            [ buttonHelper (Eth EthDescription) "Back"
                            , buttonHelper (Eth EthConfirm) "Next"
                            ]
                        ]
                    ]


inputHelper : (String -> Msg) -> String -> Element Msg
inputHelper toMsg label =
    let
        textInput =
            html <|
                Html.input [ Html.onInput toMsg, Html.style [ ( "height", "30px" ), ( "width", "300px" ) ] ]
                    []
    in
        row [ spacing 30, centerX, width shrink ]
            [ el [ Font.color Color.white, nunito, paddingXY 30 0, centerX, width shrink ] (text label)
            , textInput
            ]


buttonHelper : Step -> String -> Element Msg
buttonHelper step btnText =
    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
        { onPress = Just <| ChangeStep step, label = el [ nunito, Font.color blue, paddingXY 40 10 ] (text btnText) }


type Msg
    = NoOp
    | SetToAddress String
    | SetAmount String
    | ChangeStep Step


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        SetAmount strAmount ->
            { model | valAmount = BigInt.fromString strAmount } ! []

        SetToAddress strAddress ->
            { model | toAddress = EthUtils.toAddress strAddress |> Result.toMaybe } ! []

        ChangeStep step ->
            { model | step = step } ! []



-- smallRoboto : List (Attribute Msg)
-- smallRoboto =
--     [ roboto, Font.color Color.grey, Font.size 14, Font.light ]
