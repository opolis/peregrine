module View.Helper exposing (..)

import Color
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as Html
import Html


nunito =
    Font.family
        [ Font.typeface "Nunito"
        , Font.sansSerif
        ]


roboto =
    Font.family
        [ Font.typeface "Roboto"
        , Font.sansSerif
        ]


coinCap attrs =
    image attrs { src = "static/img/coincap.png", description = "Coin Cap logo" }


smallLogo attrs =
    image attrs { src = "static/img/small-logo.png", description = "Small Peregrin Logo" }


bigLogo attrs =
    image attrs { src = "static/img/large-logo.png", description = "Big Peregrin Logo" }


blue =
    Color.rgb 44 197 195


paddingTop n =
    paddingEach
        { top = n
        , right = 0
        , bottom = 0
        , left = 0
        }


paddingLeft n =
    paddingEach
        { top = 0
        , right = 0
        , bottom = 0
        , left = n
        }


grey =
    Color.rgb 249 249 249


darkGrey =
    Color.rgb 151 151 151


horizontalRule =
    el
        [ height <| px 1
        , width fill
        , Border.width 1
        , Border.solid
        , Border.color darkGrey
        ]
        none


noTextSelect =
    htmlAttribute <| Html.style [ ( "user-select", "none" ) ]


viewIonIcon : String -> Float -> List (Attribute msg) -> Element msg
viewIonIcon iconName size attrs =
    html <|
        Html.node "ion-icon"
            [ Html.attribute "name" iconName
            , Html.style [ ( "height", toString size ++ "px" ), ( "width", toString size ++ "px" ) ]
            ]
            [ Html.div [ Html.attribute "hidden" "true" ] [ Html.text "Opolis ftw" ] ]
