module View.ProposalList exposing (..)

import BigInt
import Color
import Element exposing (..)
import Element.Events exposing (..)
import Types exposing (..)
import View.Wizard as Wizard
import View.Helper exposing (..)
import Element.Background as BG
import Html.Attributes as Html
import Contract.DSGroup exposing (Action, GetInfo)


view : Model -> Element Msg
view model =
    case model.wizard of
        Nothing ->
            column []
                [ newProposalBar "V"
                , viewProposals model
                ]

        Just subModel ->
            column []
                [ newProposalBar "^"
                , map WizardMsg (Wizard.view subModel model.account)
                ]


viewProposals : Model -> Element Msg
viewProposals model =
    column [ width fill, height fill, BG.image "static/img/background.svg" ]
        [ column [ width fill, height shrink, padding 20, spacing 20 ]
            [ row [ alignTop, spaceEvenly, width fill ]
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
            [ text <| toString proposal.id
            , column [ width fill ]
                [ el [ alignRight ] <| text "3/3"
                , el [ alignRight ] <| text "Approvals"
                ]
            ]
        , horizontalRule
        ]


newProposalBar arrow =
    row
        [ onClick ToggleWizard
        , height (px 60)
        , BG.color grey
        , spacing 10
        , pointer
        , noTextSelect
        ]
        [ el [ nunito, centerX, centerY ] (text "NEW PROPOSAL")
        , el [ centerX, centerY ] (text arrow)
        ]
