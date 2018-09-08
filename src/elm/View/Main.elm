module View.Main exposing (..)

import Element exposing (..)
import Element.Input as Input
import Element.Background as BG
import Types exposing (..)
import Contract.DSGroup exposing (Action, GetInfo)
import Color
import View.Helper exposing (..)
import Element.Font as Font


view : Model -> Element Msg
view model =
    column [ width fill ]
        [ navBar model
        , case model.screen of
            Splash ->
                splashScreen model

            ProposalList ->
                none
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


addressInput : Element Msg
addressInput =
    let
        addressTextInput =
            { onChange = Just SetDSGroupAddress
            , text = ""
            , placeholder = Nothing
            , label = Input.labelLeft [ centerY, moveLeft 10 ] (el whiteNunito (text "Multi-sig wallet Address:"))
            }
    in
        row []
            [ Input.text [ width (px 300), centerX ] addressTextInput
            ]



-- Splash Scren


splashScreen model =
    row [ width fill, height fill, BG.image "static/img/background.svg" ]
        [ row [ spacing 100 ]
            [ column [ centerX, width shrink ]
                [ el [ centerY, nunito, Font.color Color.white, Font.size 46 ] (text "Peregrine")
                , el [ centerY, nunito, Font.color Color.white, Font.size 24 ] (text "The art of multi-signature wallets")
                ]
            , bigLogo [ centerX, height (px 336), width (px 308) ]
            ]
        ]



-- Attributes


whiteNunito =
    [ nunito, Font.color Color.white, Font.size 16 ]
