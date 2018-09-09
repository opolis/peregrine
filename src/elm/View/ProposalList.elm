module View.ProposalList exposing (..)

import BigInt
import Color
import Dict
import Element exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Eth.Units as Unit
import Types exposing (..)
import View.Wizard as Wizard
import View.Helper exposing (..)
import Element.Background as BG
import Element.Font as Font
import Html.Attributes as Html
import Contract.DSGroup exposing (Action, GetInfo)


view : Model -> Element Msg
view model =
    case model.wizard of
        Nothing ->
            column []
                [ newProposalBar (viewIonIcon "ios-arrow-dropdown" 16 [])
                , map WizardMsg (Wizard.view (height (px 0)) Wizard.init model.account model.ethUSD)
                , viewProposals model
                ]

        Just subModel ->
            column []
                [ newProposalBar (viewIonIcon "ios-arrow-dropup" 16 [])
                , map WizardMsg (Wizard.view (height (px 780)) subModel model.account model.ethUSD)
                ]


viewProposals : Model -> Element Msg
viewProposals model =
    column [ width fill, height fill, BG.image "static/img/background.svg" ]
        [ column [ width fill, height shrink, padding 20, spacing 20 ]
            [ row [ nunito, Font.size 18, Font.color Color.white, alignTop, spaceEvenly, width fill ]
                [ text "Proposals", text "Wallet" ]
            , case model.dsGroupInfo of
                Nothing ->
                    -- TODO: hackathon lol
                    none

                Just info ->
                    row [ alignTop, spacing 22 ] <|
                        List.map (viewProposal info model) model.proposals
            ]
        ]


viewProposal : GetInfo -> Model -> Proposal -> Element Msg
viewProposal info model proposal =
    column
        [ width <| px 290
        , height <| px 409
        , paddingXY 18 15
        , spacing 20
        , BG.color Color.white
        , rounded 4
        , shadow
        ]
        [ row [ width fill ]
            [ el [ nunito ] <| text <| toString proposal.id
            , column [ nunito ]
                [ el [ alignRight ] <|
                    text <|
                        (BigInt.toString proposal.action.confirmations)
                            ++ "/"
                            ++ (BigInt.toString info.quorum_)
                , el [ alignRight, Font.size 12 ] <| text "Approvals"
                ]
            ]
        , horizontalRule
        , row [ width fill ]
            [ column [ spacing 5 ]
                [ el [ nunito, Font.bold, Font.size 14 ] <| text "Type"
                , el [ roboto, Font.size 14 ] <|
                    if proposal.action.calldata == "0x" then
                        text "ETH Transfer"
                    else
                        text "DAI Transfer"
                ]
            , column [ alignRight, spacing 5 ]
                [ el [ alignRight, nunito, Font.bold, Font.size 14 ] <| text "Expiration"
                , el [ alignRight, roboto, Font.size 14 ] <| text "9/24/18" -- TODO Need to use actual date.
                ]
            ]
        , row [ width fill ]
            [ column [ spacing 5 ]
                [ el [ nunito, Font.bold, Font.size 14 ] <| text "Address"
                , el [ roboto, Font.size 14 ] <| text <| shortAddress proposal.action.target
                ]
            , if proposal.action.calldata /= "0x" then
                none
              else
                column [ alignRight, spacing 5 ]
                    [ el [ alignRight, nunito, Font.bold, Font.size 14 ] <| text "Amount"
                    , el [ alignRight, roboto, Font.size 14 ] <| text <| Unit.fromWei Unit.Ether proposal.action.value
                    ]
            ]
        , el [ nunito, Font.bold, Font.size 14 ] <| text "Description"
        , paragraph [ width fill, roboto, Font.size 14, moveUp 10 ]
            [ text proposal.description ]
        , proposalButton (Dict.get proposal.id model.pendingTxs) proposal.id model ((BigInt.toString proposal.action.confirmations) == (BigInt.toString info.quorum_))
        ]


proposalButton : Maybe TxState -> Int -> Model -> Bool -> Element Msg
proposalButton proposalState proposalId model isApproved =
    case proposalState of
        Just Signing ->
            Input.button [ centerX, centerY, height (px 40), BG.color blue, rounded 5, shadow, moveDown 20 ]
                { onPress = Nothing, label = el [ nunito, Font.color Color.white, Font.size 18, paddingXY 30 10, noTextSelect ] (text "Please Sign...") }

        Just Pending ->
            Input.button [ centerX, centerY, height (px 40), width (px 130), BG.color blue, rounded 5, shadow, moveDown 20 ]
                { onPress = Nothing
                , label =
                    column [ moveUp 80, paddingXY 30 10 ]
                        [ pendingGif [ height (px 80), moveUp 10 ]
                        , el [ nunito, Font.color Color.white, Font.size 18 ] (text "Pending...")
                        ]
                }

        _ ->
            case isApproved of
                False ->
                    Input.button [ centerX, centerY, height (px 40), BG.color blue, rounded 5, shadow, moveDown 20 ]
                        { onPress =
                            case model.account of
                                Just _ ->
                                    Just (ConfirmProposal proposalId)

                                Nothing ->
                                    Nothing
                        , label = el [ nunito, Font.color Color.white, Font.size 18, paddingXY 30 10, noTextSelect ] (text "Approve")
                        }

                True ->
                    Input.button [ centerX, centerY, height (px 40), BG.color blue, rounded 5, shadow, moveDown 20 ]
                        { onPress =
                            case model.account of
                                Just _ ->
                                    Nothing

                                Nothing ->
                                    Nothing
                        , label = el [ nunito, Font.color Color.white, Font.size 18, paddingXY 30 10, noTextSelect ] (text "Approved!")
                        }


newProposalBar icon =
    row
        [ onClick ToggleWizard
        , height (px 60)
        , BG.color grey
        , spacing 10
        , pointer
        , noTextSelect
        ]
        [ el [ nunito, centerX, centerY ] (text "NEW PROPOSAL")
        , el [ centerX, centerY ] icon
        ]
