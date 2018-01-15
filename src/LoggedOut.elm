module LoggedOut exposing (..)

import Element exposing (button, column, el, empty, html, row, table, text)
import Element.Attributes exposing (..)
import Element.Input as Input
import Html
import Html.Attributes as Attr
import Misc exposing (materialIcon, onClickPreventDefault)
import Msgs exposing (Msg(LoginRequested, NoOp, EmailEdited, PasswordEdited))
import Styles exposing (MyStyles(..))


type alias Model =
    {}


viewTextInput ( changeMsg, label ) =
    Input.text NoStyle
        [ height (px 30) ]
        { onChange = changeMsg
        , value = ""
        , label = Input.labelLeft empty
        , options = []
        }


viewLoggedOut =
    column NoStyle
        [ height fill, width fill, verticalCenter, spacing 10 ]
        [ el NoStyle [center] (html (Html.h1 [] [Html.text "4OfUs"]))
        , row NoStyle
            [ center, verticalCenter, paddingXY 50 10, spacing 20 ]
            [ materialIcon "mail" "grey"
            , Input.email NoStyle
                []
                (Input.Text EmailEdited
                    ""
                    (Input.placeholder
                        { text = "Email"
                        , label = Input.hiddenLabel ""
                        }
                    )
                    []
                )
            ]
        , row NoStyle
            [ center, verticalCenter, paddingXY 50 10, spacing 20 ]
            [ materialIcon "lock" "grey"
            , Input.currentPassword NoStyle
                []
                (Input.Text PasswordEdited
                    ""
                    (Input.placeholder
                        { text = "Password"
                        , label = Input.hiddenLabel ""
                        }
                    )
                    []
                )
            ]
        , row NoStyle
            [ center, spacing 10 ]
            [ button NoStyle
                [ paddingXY 40 10, onClickPreventDefault LoginRequested
                , class "waves-effect waves-light btn"
                ]
                (el NoStyle [] (text "Log In"))
            ]
        ]
