module View.Wizard exposing (..)

import Element exposing (..)


type alias Model =
    { screen : Step }


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


view : Element Msg
view =
    none


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []
