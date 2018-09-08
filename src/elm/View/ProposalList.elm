module View.ProposalList exposing (..)

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
                ]

        Just subModel ->
            column []
                [ newProposalBar "^"
                , map WizardMsg (Wizard.view subModel)
                ]


newProposalBar arrow =
    row
        [ onClick ToggleWizard
        , height (px 60)
        , BG.color grey
        , spacing 10
        , pointer
        , htmlAttribute <| Html.style [ ( "user-select", "none" ) ]
        ]
        [ el [ nunito, centerX, centerY ] (text "NEW PROPOSAL")
        , el [ centerX, centerY ] (text arrow)
        ]
