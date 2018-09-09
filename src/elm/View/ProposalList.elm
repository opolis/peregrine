module View.ProposalList exposing (..)

import BigInt
import Color
import Element exposing (..)
import Element.Events exposing (..)
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
                , viewProposals model
                ]

        Just subModel ->
            column []
                [ newProposalBar (viewIonIcon "ios-arrow-dropup" 16 [])
                , map WizardMsg (Wizard.view subModel model.account)
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
                        List.map (viewProposal info) model.proposals
            ]
        ]


viewProposal : GetInfo -> Proposal -> Element Msg
viewProposal info proposal =
    column
        [ width <| px 290
        , height <| px 409
        , paddingXY 18 15
        , spacing 13
        , BG.color Color.white
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
                , el [ roboto, Font.size 14 ] <| text "ETH Transfer"
                ]
            , column [ alignRight, spacing 5 ]
                [ el [ alignRight, nunito, Font.bold, Font.size 14 ] <| text "Expiration"
                , el [ alignRight, roboto, Font.size 14 ] <| text <| BigInt.toString proposal.action.deadline
                ]
            ]
        , row [ width fill ]
            [ column [ spacing 5 ]
                [ el [ nunito, Font.bold, Font.size 14 ] <| text "Address"
                , el [ roboto, Font.size 14 ] <| text <| shortAddress proposal.action.target
                ]
            , column [ alignRight, spacing 5 ]
                [ el [ alignRight, nunito, Font.bold, Font.size 14 ] <| text "Amount"
                , el [ alignRight, roboto, Font.size 14 ] <| text <| Unit.fromWei Unit.Ether proposal.action.value
                ]
            ]
        , el [ nunito, Font.bold, Font.size 14 ] <| text "Description"
        , paragraph [ width fill, roboto, Font.size 14 ]
            [ text proposal.description
            ]
        ]


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
