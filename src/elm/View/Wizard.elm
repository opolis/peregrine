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
import Eth.Types exposing (..)
import BigInt exposing (BigInt)


type alias Model =
    { step : Step
    , toAddress : Maybe Address
    , valAmount : Maybe BigInt
    , desc : String
    }


init : Model
init =
    { step = Choose
    , toAddress = Nothing
    , valAmount = Nothing
    , desc = ""
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


view : Model -> Maybe Address -> Element Msg
view model userAddress =
    column [ BG.image "static/img/background.svg", height fill ]
        [ case model.step of
            Choose ->
                viewChoose

            Eth ethStep ->
                viewEthForm model ethStep userAddress

            Contract contractStep ->
                viewContractForm model contractStep userAddress
        ]


viewChoose : Element Msg
viewChoose =
    column []
        [ column [ Font.color Color.white, nunito, centerY, height shrink, spacing 60 ]
            [ el [ centerX ] (text "What would you like to do?")
            , row [ spacing 50 ]
                [ buttonHelperStep (Eth EthChooseAddress) "Send Eth"
                , buttonHelperStep (Contract ContractChoice) "Interact With Contract"
                ]
            ]
        ]


viewEthForm : Model -> EthStep -> Maybe Address -> Element Msg
viewEthForm model ethStep userAddress =
    let
        addressStr =
            Maybe.map EthUtils.addressToString model.toAddress
                |> Maybe.withDefault "Error parsing address"

        valStr =
            Maybe.map BigInt.toString model.valAmount
                |> Maybe.withDefault "Error parsing value"
    in
        case ethStep of
            EthChooseAddress ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white, centerX ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 1 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Where would you like to send Eth?")
                        , inputHelper SetToAddress "Address:"
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Choose) "Back"
                            , buttonHelperStep (Eth EthChooseAmount) "Next"
                            ]
                        ]
                    ]

            EthChooseAmount ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 2 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "How much ether would you like to send?")
                        , row [ Font.color Color.white, nunito ]
                            [ el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "to: ")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text addressStr)
                            ]
                        , inputHelper SetAmount "Amount:"
                        , row [ Font.color Color.white, nunito ]
                            [ el [ centerX ] (text "Powered By ")
                            , coinCap [ height (px 57), width (px 126) ]
                            , el [ centerX, paddingLeft 5 ] (text <| "$" ++ "0.00")
                            ]
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthChooseAddress) "Back"
                            , buttonHelperStep (Eth EthDescription) "Next"
                            ]
                        ]
                    ]

            EthDescription ->
                column []
                    [ column [ centerY, centerX, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 3 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Why would you like to do this?")
                        , el [ centerX, width shrink ] <| multiLineInput SetDescription
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthChooseAmount) "Back"
                            , buttonHelperStep (Eth EthConfirm) "Next"
                            ]
                        ]
                    ]

            EthConfirm ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 4 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Confirm Proposal")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "to: " ++ addressStr)
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "send: " ++ valStr ++ " Eth")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "message: " ++ model.desc)
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthDescription) "Back"
                            , case ( userAddress, model.toAddress, model.valAmount ) of
                                ( Just userAddress_, Just toAddress_, Just valAmount_ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Just <| Propose userAddress_ toAddress_ valAmount_ (EthUtils.unsafeToHex "0x0") model.desc
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Propose")
                                        }

                                ( _, _, _ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Nothing, label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Form Error") }
                            ]
                        ]
                    ]


viewContractForm : Model -> ContractStep -> Maybe Address -> Element Msg
viewContractForm model contractStep userAddress =
    let
        addressStr =
            Maybe.map EthUtils.addressToString model.toAddress
                |> Maybe.withDefault "Error parsing address"

        valStr =
            Maybe.map BigInt.toString model.valAmount
                |> Maybe.withDefault "Error parsing value"
    in
        case contractStep of
            ContractChoice ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white, centerX ]
                            [ el [ centerX, nunito, Font.bold ] (text "Interact with Contract")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 1 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Where would you like to send Eth?")
                        , inputHelper SetToAddress "Address:"
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Choose) "Back"
                            , buttonHelperStep (Contract FunctionChoice) "Next"
                            ]
                        ]
                    ]

            FunctionChoice ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Interact with Contract")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 2 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "How much ether would you like to send?")
                        , row [ Font.color Color.white, nunito ]
                            [ el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "to: ")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text addressStr)
                            ]
                        , inputHelper SetAmount "Amount:"
                        , row [ Font.color Color.white, nunito ]
                            [ el [ centerX ] (text "Powered By Coincap")
                            , el [ centerX ] (text <| "$" ++ "0.00")
                            ]
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Contract ContractChoice) "Back"
                            , buttonHelperStep (Contract ContractDescription) "Next"
                            ]
                        ]
                    ]

            ContractDescription ->
                column []
                    [ column [ centerY, centerX, height shrink, spacing 60 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Interact with Contract")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 3 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Why would you like to do this?")
                        , el [ centerX, width shrink ] <| multiLineInput SetDescription
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Contract FunctionChoice) "Back"
                            , buttonHelperStep (Contract ContractConfirm) "Next"
                            ]
                        ]
                    ]

            ContractConfirm ->
                column []
                    [ column [ centerY, height shrink, spacing 40 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Interact with Contract")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 4 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Confirm Proposal")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "to: " ++ addressStr)
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "send: " ++ valStr ++ " Eth")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.light ] (text <| "message: " ++ model.desc)
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Contract ContractDescription) "Back"
                            , case ( userAddress, model.toAddress, model.valAmount ) of
                                ( Just userAddress_, Just toAddress_, Just valAmount_ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Just <| Propose userAddress_ toAddress_ valAmount_ (EthUtils.unsafeToHex "0x0") model.desc
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Propose")
                                        }

                                ( _, _, _ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Nothing, label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Form Error") }
                            ]
                        ]
                    ]


inputHelper : (String -> Msg) -> String -> Element Msg
inputHelper toMsg label =
    let
        textInput =
            html <|
                Html.input [ Html.onInput toMsg, Html.style [ ( "height", "30px" ), ( "width", "300px" ), ( "margin", "auto" ) ] ]
                    []
    in
        row [ spacing 30, centerX, width shrink ]
            [ el [ Font.color Color.white, nunito, paddingXY 30 0, centerX, width shrink ] (text label)
            , textInput
            ]


multiLineInput : (String -> Msg) -> Element Msg
multiLineInput toMsg =
    html <|
        Html.textarea [ Html.onInput toMsg, Html.style [ ( "height", "90px" ), ( "width", "280px" ) ] ]
            []


buttonHelperStep : Step -> String -> Element Msg
buttonHelperStep step btnText =
    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
        { onPress = Just <| ChangeStep step, label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text btnText) }


buttonHelper : Msg -> String -> Element Msg
buttonHelper msg btnText =
    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
        { onPress = Just msg, label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text btnText) }



-- for dai etc buttons, pass in noop


type Msg
    = NoOp
    | SetToAddress String
    | SetAmount String
    | SetDescription String
    | ChangeStep Step
    | Propose Address Address BigInt Hex String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        SetAmount strAmount ->
            { model | valAmount = BigInt.fromString strAmount } ! []

        SetToAddress strAddress ->
            { model | toAddress = EthUtils.toAddress strAddress |> Result.toMaybe } ! []

        SetDescription strDesc ->
            { model | desc = strDesc } ! []

        ChangeStep step ->
            { model | step = step } ! []

        Propose userAddress toAddress txValue hexData desc ->
            -- Caught in Parent module
            model ! []
