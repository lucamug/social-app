module LoggedOut exposing (..)

import Data exposing (LoggedOutStatus(..))
import Element exposing (button, column, el, empty, html, modal, row, screen, text)
import Element.Attributes exposing (..)
import Element.Input exposing (Text, currentPassword, email, hiddenLabel, placeholder)
import CreateProfile exposing(viewCreateProfile)
import Html
import Html.Attributes as Attr
import Misc exposing (materialIcon, onClickPreventDefault)
import Msgs exposing (Msg(ProfileCreationCanceled, ProfileFormRequested, EmailEdited, LoginRequested, PasswordEdited))
import Styles exposing (MyStyles(..))

type alias Model =
    { usernameEntry: String
    , emailEntry: String
    , passwordEntry: String
    }



viewLoggedOut loginStatus =
    column NoStyle
        [ class "green lighten-2", height fill, width fill, verticalCenter, paddingXY 50 10 ]
        -- Title
        [ el NoStyle [ center ] (html (Html.h1 [] [ Html.text "2 Of Us" ]))

        -- Email Input
        , row NoStyle
            [ verticalCenter, spacing 20, paddingBottom 20 ]
            [ materialIcon "mail" "green"
            , email NoStyle
                [ paddingLeft 10 ]
                (Text EmailEdited "" (placeholder { text = "Email", label = hiddenLabel "" }) [])
            ]

        -- Password Input
        , row NoStyle
            [ verticalCenter, spacing 20, paddingBottom 3 ]
            [ materialIcon "lock" "green"
            , currentPassword NoStyle
                [ paddingLeft 10 ]
                (Text PasswordEdited "" (placeholder { text = "Password", label = hiddenLabel "" }) [])
            ]

        -- Forgot password button
        , row NoStyle
            [ alignRight, paddingBottom 20 ]
            [ button NoStyle [ class "waves-effect waves-teal btn-flat" ] (text "Forgot Password?")
            ]

        -- Login Button
        , row NoStyle
            []
            [ button NoStyle
                [ width fill
                , onClickPreventDefault LoginRequested
                , class "waves-effect waves-light btn red"
                ]
                (text "Log In")
            ]

        -- Create Free Profile Button
        , row NoStyle
            [ center, padding 30 ]
            [ button NoStyle
                [ padding 10
                , onClickPreventDefault ProfileFormRequested
                , class "waves-effect waves-light btn"
                ]
                (text "Create free profile")
            ]
        , viewCreateProfile loginStatus
        ]
