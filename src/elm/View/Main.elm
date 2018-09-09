module View.Main exposing (..)

import Element exposing (..)
import Element.Input as Input
import Element.Background as BG
import Types exposing (..)
import Color
import View.Helper exposing (..)
import View.ProposalList as PropList
import Element.Font as Font


view : Model -> Element Msg
view model =
    column [ width fill ]
        [ ledgerStatusBar model
        , navBar model
        , case model.screen of
            Splash ->
                splashScreen

            ProposalList ->
                PropList.view model
        ]



-- NavBar


navBar : Model -> Element Msg
navBar model =
    row
        [ width fill
        , height (px 60)
        , BG.color Color.black
        ]
        [ smallLogo [ height (px 36), width (px 33), moveDown 2, moveRight 20 ]
        , addressInput
        ]


ledgerStatusBar : Model -> Element Msg
ledgerStatusBar model =
    case model.account of
        Nothing ->
            row [ height (px 20), BG.color Color.red ]
                [ el [ centerX, nunito, Font.color Color.white, Font.size 12 ] (text "Missing Ledger Wallet") ]

        Just _ ->
            none


addressInput : Element Msg
addressInput =
    let
        addressTextInput =
            { onChange = Just SetDSGroupAddress
            , text = ""
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY, moveLeft 10 ] (el greyRoboto (text "Multi-sig wallet Address:"))
            }
    in
        row [] [ Input.text [ width (px 300), centerX ] addressTextInput ]



-- Splash Screen


splashScreen : Element Msg
splashScreen =
    row [ width fill, height fill, BG.image "static/img/background.svg" ]
        [ row [ spacing 100 ]
            [ column [ centerX, width shrink ]
                [ el [ centerY, nunito, Font.color Color.white, Font.size 46 ] (text "Peregrine")
                , el [ centerY, nunito, Font.color Color.white, Font.size 24, paddingTop 10 ] (text "The art of multi-signature wallets")
                ]
            , bigLogo [ centerX, height (px 336), width (px 308) ]
            ]
        ]



-- Attributes


whiteNunito : List (Attribute Msg)
whiteNunito =
    [ nunito, Font.color Color.white, Font.size 16 ]


greyRoboto =
    [ roboto, Font.color Color.grey, Font.size 16, Font.light ]
