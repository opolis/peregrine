module View.Main exposing (..)

import Element exposing (..)
import Element.Input as Input
import Element.Background as BG
import Element.Events exposing (..)
import Types exposing (..)
import Color
import View.Helper exposing (..)
import View.ProposalList as PropList
import Element.Font as Font


view : Model -> Element Msg
view model =
    column [ width fill ]
        [ if model.screen == Splash then
            none
          else
            ledgerStatusBar model
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
        [ el [ onClick InitLedger, pointer, width (px 100) ] (smallLogo [ height (px 36), width (px 33), moveDown 2, moveRight 20 ])
        , addressInput
        ]


ledgerStatusBar : Model -> Element Msg
ledgerStatusBar model =
    case model.account of
        Nothing ->
            row [ height (px 20), BG.color <| Color.rgb 200 94 94 ]
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
    row [ width fill, height fill, BG.image "static/img/background.svg", onClick PassSplash, pointer ]
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
