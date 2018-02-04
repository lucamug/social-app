module CreateProfile exposing (..)

import Data exposing (LoggedOutStatus(..))
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Input exposing (Text, currentPassword, email, hiddenLabel, placeholder)
import Misc exposing (materialIcon, onClickPreventDefault)
import Msgs exposing (Msg(..))
import Styles exposing (MyStyles(..))


viewCreateProfile loginStatus =
    screen
        (column Modal
            [ inlineStyle
                [ ( "left"
                  , if loginStatus == LoggingIn then
                        "-100%"
                    else
                        "0"
                  )
                ]
            , width fill
            , height fill
            ]
            [ row YellowBar
                [ width fill
                , height (px 60)
                , padding 10
                , alignLeft
                , verticalCenter
                ]
                [ el NoStyle
                    [ class "btn-floating waves-effect btn-flat red"
                    , width (px 40)
                    , onClickPreventDefault ProfileCreationCanceled
                    ]
                    (materialIcon "chevron_left" "white")
                , row NoStyle [center, width fill] [text "Create Profile"]
                ]
            , column WhiteBg
                [ verticalCenter,spacing 20, padding 30, height fill ]

                -- Email Input
                [ row NoStyle
                    [verticalCenter, spacing 10] 
                    [ materialIcon "account_circle" "green"
                    , email NoStyle
                        [ paddingLeft 10 ]
                        (Text UsernameEdited "" (placeholder { text = "Username", label = hiddenLabel "" }) [])
                    ]
                , row NoStyle
                    [verticalCenter, spacing 10] 
                    [ materialIcon "mail" "green"
                    , email NoStyle
                        [ paddingLeft 10 ]
                        (Text EmailEdited "" (placeholder { text = "Email", label = hiddenLabel "" }) [])
                    ]

                , row NoStyle
                    [verticalCenter, spacing 10]
                    [ materialIcon "lock" "green"
                    , currentPassword NoStyle
                        [ paddingLeft 10 ]
                        (Text PasswordEdited "" (placeholder { text = "Password", label = hiddenLabel "" }) [])
                    ]
                , spacer 1
                -- Login Button
                , row NoStyle
                    []
                    [ button NoStyle
                        [ width fill
                        , onClickPreventDefault SubmitProfileRequested
                        , class "waves-effect waves-light btn red"
                        ]
                        (text "Create Profile")
                    ]
                ]
            ]
        )
