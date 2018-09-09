module View.Helper exposing (..)

import Color
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as Html


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
