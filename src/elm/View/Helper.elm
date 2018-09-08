module View.Helper exposing (..)

import Element.Font as Font
import Element exposing (..)


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
