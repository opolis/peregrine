module Contract.Helpers exposing (..)

import BigInt exposing (BigInt)
import Contract.DSGroup as DSGroup exposing (Action)
import Eth.Types exposing (Address, HttpProvider)
import Eth
import Task exposing (Task)
import Http


getProposals : HttpProvider -> Address -> Task Http.Error (List Action)
getProposals node dsgroup =
    Eth.call node (DSGroup.actionCount dsgroup)
        |> Task.andThen
            (\count ->
                countDownFrom count
                    |> List.map (Eth.call node << DSGroup.actions dsgroup)
                    |> Task.sequence
            )



-- BigInt Helpers


countDownFrom : BigInt -> List BigInt
countDownFrom num =
    let
        countDownHelper num acc =
            case BigInt.compare num one of
                EQ ->
                    one :: acc

                _ ->
                    countDownHelper (BigInt.sub num one) (num :: acc)
    in
        case BigInt.lte num zero of
            True ->
                []

            False ->
                countDownHelper num []


zero : BigInt
zero =
    BigInt.fromInt 0


one : BigInt
one =
    BigInt.fromInt 1
