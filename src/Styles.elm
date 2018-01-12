module Styles exposing (..)

import Color exposing (black, blue, darkGrey, lightBlue, red, white, yellow)
import Style exposing (StyleSheet, style)
import Style.Border as Border
import Style.Color as Color
import Style.Shadow as Shadow
import Style.Transition exposing (Transition, all, transitions)


type MyStyles
    = NavBar
    | Pusher
    | NoStyle
    | Avatar
    | YellowBar
    | Header
    | Button
    | Sidebar
    | Main
    | Underline


stylesheet : StyleSheet MyStyles variation
stylesheet =
    Style.styleSheet
        [ style NavBar
            [ Color.background lightBlue
            ]
        , style YellowBar [ Color.background yellow ]
        , style Header [ Color.background blue ]
        , style Button
            [ Color.text (Color.rgb 256 256 256)
            , Color.background red
            , Shadow.glow (Color.rgba 128 128 128 0.6) 2
            , Border.rounded 8
            ]
        , style Pusher [ transitions [ Transition 0 130 "ease-in" [ "width" ] ] ]
        , style Main [ Color.background darkGrey ]
        , style Underline []
        , style NoStyle []
        , style Avatar [ Border.rounded 1000 ]
        , style Sidebar [ Color.background red ]
        ]