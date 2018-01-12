module LoggedOut exposing (..)

import Element exposing (button, column, el, row, text, empty, table, html)
import Element.Attributes exposing (..)
import Element.Input as Input
import Misc exposing (onClickPreventDefault)
import Msgs exposing (Msg(LogInRequested, NoOp, UsernameAdded))
import Styles exposing (MyStyles(..))
import Html
import Html.Attributes as Attr


type alias Model =
    {}

viewTextInput (changeMsg, label) = 
    Input.text NoStyle
        [height (px 30)]
        { onChange = changeMsg
        , value = ""
        , label = Input.labelLeft empty 
        , options = []
        }
    

viewLoggedOut =
    let
        textInputs = [(UsernameAdded, "Email: "), (UsernameAdded, "Password: ")]
    in
        
    column NoStyle
        [ height fill, width fill, verticalCenter, spacing 10]
        [ row NoStyle
            [padding 20, center]
            [html (Html.div [Attr.class "input-field"][Html.input [Attr.placeholder "Email"][]
                , Html.label [][]])]
        , row NoStyle
            [ center, spacing 10 ]
            [ html (Html.button [onClickPreventDefault LogInRequested, Attr.classList [("waves-effect", True), ("waves-light", True), ("btn", True)]][Html.text "Button Dog"])]
        ]
