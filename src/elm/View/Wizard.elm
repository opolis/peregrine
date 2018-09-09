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
import Abi.Encode as AbiEncode exposing (Encoding(..), abiEncode)


type alias Model =
    { step : Step
    , toAddress : Maybe Address
    , valAmount : Maybe BigInt
    , desc : String
    , isPending : Bool
    }


init : Model
init =
    { step = Choose
    , toAddress = Nothing
    , valAmount = Nothing
    , desc = ""
    , isPending = False
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


view : Attribute Msg -> Model -> Maybe Address -> Maybe Float -> Element Msg
view heightAttr model userAddress ethToUsd =
    column [ BG.image "static/img/background.svg", heightAttr ]
        [ column [ BG.color (Color.rgba 175 175 175 0.2), heightAttr, transitionAttr ]
            [ case model.step of
                Choose ->
                    viewChoose

                Eth ethStep ->
                    viewEthForm model ethStep userAddress ethToUsd

                Contract contractStep ->
                    viewContractForm model contractStep userAddress
            ]
        ]


transitionAttr =
    htmlAttribute <| Html.style [ ( "transition", "height 400ms" ) ]


viewChoose : Element Msg
viewChoose =
    column []
        [ column [ Font.color Color.white, nunito, centerY, height shrink, spacing 60 ]
            [ el [ centerX ] (text "What would you like to do?")
            , row [ spacing 50 ]
                [ buttonHelperStep (Eth EthChooseAddress) (stringHelper "Send Eth") [ Font.color blue ]
                , buttonHelperStep (Contract ContractChoice) (stringHelper "Interact With Contract") [ Font.color blue ]
                ]
            ]
        ]


viewEthForm : Model -> EthStep -> Maybe Address -> Maybe Float -> Element Msg
viewEthForm model ethStep userAddress ethToUsd =
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
                    [ column [ centerY, height shrink, spacing 50 ]
                        [ column [ Font.color Color.white, centerX ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 1 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 50 ] (text "Where would you like to send Eth?")
                        , inputHelper SetToAddress "Address:"
                        , row [ spacing 50, paddingTop 45 ]
                            [ buttonHelperStep (Choose) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , buttonHelperStep (Eth EthChooseAmount) forwardHelper [ Font.color blue ]
                            ]
                        ]
                    ]

            EthChooseAmount ->
                column []
                    [ column [ centerY, height shrink, spacing 30 ]
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
                            , coinCap [ height (px 38), width (px 83) ]
                            , el [ centerX, paddingLeft 5 ] (text <| "$" ++ coinCapPriceHelper ethToUsd model.valAmount)
                            ]
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthChooseAddress) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , buttonHelperStep (Eth EthDescription) forwardHelper [ Font.color blue ]
                            ]
                        ]
                    ]

            EthDescription ->
                column []
                    [ column [ centerY, centerX, height shrink, spacing 50 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Send Eth")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 3 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Why would you like to do this?")
                        , el [ centerX, width shrink ] <| multiLineInput SetDescription
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthChooseAmount) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , buttonHelperStep (Eth EthConfirm) forwardHelper [ Font.color blue ]
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
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "to: " ++ addressStr)
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "send: " ++ valStr ++ " Eth")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "message: " ++ model.desc)
                        , row [ spacing 50 ]
                            [ buttonHelperStep (Eth EthDescription) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , case ( userAddress, model.toAddress, model.valAmount, model.isPending ) of
                                ( _, _, _, True ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Nothing
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Pending...")
                                        }

                                ( Just userAddress_, Just toAddress_, Just valAmount_, _ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Just <| Propose userAddress_ toAddress_ (toEth valAmount_) (EthUtils.unsafeToHex "0x0") model.desc
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Propose")
                                        }

                                ( _, _, _, _ ) ->
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
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Interact with Which Contract?")
                        , Input.button [ centerX, centerY, BG.color Color.white, height (px 40), width (px 260), paddingEach { top = 3, right = 3, bottom = 3, left = 3 } ]
                            { onPress = Just <| ChangeStep (Contract FunctionChoice), label = el [ nunito, Font.size 14, Font.color blue, noTextSelect ] (text "DAI") }
                        , Input.button [ centerX, centerY, BG.color Color.white, height (px 40), width (px 260), paddingEach { top = 3, right = 3, bottom = 3, left = 3 } ]
                            { onPress = Nothing, label = el [ nunito, Font.size 14, Font.color blue, noTextSelect ] (text "Add contract") }
                        , row [ spacing 70, paddingTop 40 ]
                            [ buttonHelperStep (Choose) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            ]
                        ]
                    ]

            FunctionChoice ->
                column []
                    [ column [ centerY, height shrink, spacing 30 ]
                        [ column [ Font.color Color.white ]
                            [ el [ centerX, nunito, Font.bold ] (text "Interact with Contract")
                            , el [ centerX, roboto, Font.light, Font.size 16, paddingTop 5 ] (text "Step 2 of 4")
                            ]
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "What function would you like to call?")
                        , Input.button [ centerX, centerY, BG.color Color.white, height (px 40), width (px 260), paddingEach { top = 3, right = 3, bottom = 3, left = 3 } ]
                            { onPress = Just <| ChangeStep (Contract ContractDescription), label = el [ nunito, Font.size 14, Font.color blue, noTextSelect ] (text "Transfer") }
                        , Input.button [ centerX, centerY, BG.color Color.white, height (px 40), width (px 260), paddingEach { top = 3, right = 3, bottom = 3, left = 3 } ]
                            { onPress = Nothing, label = el [ nunito, Font.size 14, Font.color blue, noTextSelect ] (text "Transfer From") }
                        , row [ spacing 70, paddingTop 10 ]
                            [ buttonHelperStep (Contract ContractChoice) backHelper [ BG.color nearBlack, Font.color darkGrey ]
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
                        , inputHelper SetToAddress "Address:"
                        , inputHelper SetAmount "Amount:"
                        , el [ Font.color Color.white, roboto, Font.light, Font.size 32, centerX, paddingTop 40 ] (text "Add description")
                        , el [ centerX, width shrink ] <| multiLineInput SetDescription
                        , row [ spacing 70, paddingTop 5 ]
                            [ buttonHelperStep (Contract FunctionChoice) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , buttonHelperStep (Contract ContractConfirm) forwardHelper [ Font.color blue ]
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
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "contract: " ++ addressStr)
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "function: " ++ valStr ++ " Eth")
                        , el [ Font.color Color.white, nunito, centerX, roboto, Font.size 14, Font.light ] (text <| "message: " ++ model.desc)
                        , row [ spacing 70, paddingTop 39 ]
                            [ buttonHelperStep (Contract ContractDescription) backHelper [ BG.color nearBlack, Font.color darkGrey ]
                            , case ( userAddress, model.toAddress, model.valAmount, model.isPending ) of
                                ( _, _, _, True ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Nothing
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Pending...")
                                        }

                                ( Just userAddress_, Just toAddress_, Just valAmount_, _ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Just <| Propose userAddress_ daiTokenContract (BigInt.fromInt 0) (ercTransfer toAddress_ valAmount_) model.desc
                                        , label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Propose")
                                        }

                                ( _, _, _, _ ) ->
                                    Input.button [ centerX, centerY, height (px 60), BG.color grey ]
                                        { onPress = Nothing, label = el [ nunito, Font.color blue, paddingXY 40 10, noTextSelect ] (text "Error") }
                            ]
                        ]
                    ]


coinCapPriceHelper : Maybe Float -> Maybe BigInt -> String
coinCapPriceHelper ethToUsd coinPrice =
    Maybe.map (round >> BigInt.fromInt) ethToUsd
        |> Maybe.andThen (\ethToUsd_ -> Maybe.map (BigInt.mul ethToUsd_ >> BigInt.toString) coinPrice)
        |> Maybe.withDefault "0.00"


toEth val =
    BigInt.pow (BigInt.fromInt 10) (BigInt.fromInt 18)
        |> BigInt.mul val


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


backHelper =
    row [ width (px 120), centerX, paddingXY 20 20 ] [ viewIonIcon "arrow-dropleft-circle" 20 [], el [ centerX ] (text "Back") ]


forwardHelper =
    row [ width (px 120), centerX, paddingXY 20 20 ] [ el [ centerX ] (text "Next"), viewIonIcon "arrow-dropright-circle" 20 [ centerX ] ]


stringHelper : String -> Element Msg
stringHelper btnText =
    row [ width (px 250), centerX, paddingXY 20 20 ] [ el [ centerX ] (text btnText) ]


multiLineInput : (String -> Msg) -> Element Msg
multiLineInput toMsg =
    html <|
        Html.textarea [ Html.onInput toMsg, Html.style [ ( "height", "90px" ), ( "width", "280px" ) ] ]
            []


buttonHelperStep : Step -> Element Msg -> List (Attribute Msg) -> Element Msg
buttonHelperStep step btnEl attrs =
    Input.button ([ centerX, centerY, height (px 60), BG.color grey ] ++ attrs)
        { onPress = Just <| ChangeStep step
        , label = btnEl
        }


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
            { model | isPending = True } ! []


daiTokenContract : Address
daiTokenContract =
    EthUtils.unsafeToAddress "0xc384099c131cfbe5d5ffee25d9eb51f9f6a77626"


ercTransfer : Address -> BigInt.BigInt -> Hex
ercTransfer dst wad =
    AbiEncode.functionCall "transfer(address,uint256)" [ AbiEncode.address dst, AbiEncode.uint wad ]
