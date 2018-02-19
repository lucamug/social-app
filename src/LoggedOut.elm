module LoggedOut exposing (..)

import Element exposing (button, column, el, empty, html, modal, row, screen, text, spacer)
import Element.Attributes exposing (..)
import Element.Input exposing (Text, currentPassword, email, hiddenLabel, placeholder)
import Html
import Ports
import Misc exposing (materialIcon, onClickPreventDefault)
import Styles exposing (MyStyles(..))


------ MODEL -------------------


type alias Model =
    { status : LoggedOutStatus
    , usernameEntry : String
    , passwordEntry : String
    , emailEntry : String
    }


initialModel : Model
initialModel =
    { status = LoggingIn
    , usernameEntry = ""
    , passwordEntry = ""
    , emailEntry = ""
    }


type LoggedOutStatus
    = LoggingIn
    | CreatingAccount
    | RetrievingPassword



----- Update --------------------


type Msg
    = SubmitProfileRequested
    | EmailEdited String
    | PasswordEdited String
    | UsernameEdited String
    | ProfileCreationCanceled
    | ProfileFormRequested
    | LoginRequested


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ProfileCreationCanceled ->
            { model | status = LoggingIn } ! []

        EmailEdited email ->
            { model | emailEntry = email } ! []

        PasswordEdited password ->
            { model | passwordEntry = password } ! []

        UsernameEdited username ->
            { model | usernameEntry = username } ! []

        ProfileFormRequested ->
            { model | status = CreatingAccount } ! []

        SubmitProfileRequested ->
            model ! [ Ports.newUser { username = model.usernameEntry, email = model.emailEntry, password = model.passwordEntry } ]

        LoginRequested ->
            model ! [ Ports.login { email = model.emailEntry, password = model.passwordEntry } ]



------------- VIEW --------------------------------


viewLoggedOut : Model -> Element.Element MyStyles variation Msg
viewLoggedOut model =
    column NoStyle
        [ class "green lighten-2"
        , height fill
        , width fill
        , verticalCenter
        , paddingXY 50 10
        ]
        -- Title
        [ el NoStyle
            [ center ]
            (html
                (Html.h1 []
                    [ Html.text "2 Of Us" ]
                )
            )

        -- Email Input
        , row NoStyle
            [ verticalCenter, spacing 20, paddingBottom 20 ]
            [ materialIcon "mail" "green"
            , email NoStyle
                [ paddingLeft 10 ]
                (Text EmailEdited
                    model.emailEntry
                    (placeholder
                        { text = "Email"
                        , label = hiddenLabel ""
                        }
                    )
                    []
                )
            ]

        -- Password Input
        , row NoStyle
            [ verticalCenter, spacing 20, paddingBottom 3 ]
            [ materialIcon "lock" "green"
            , currentPassword NoStyle
                [ paddingLeft 10 ]
                (Text PasswordEdited
                    model.passwordEntry
                    (placeholder
                        { text = "Password"
                        , label = hiddenLabel ""
                        }
                    )
                    []
                )
            ]

        -- Forgot password button
        , row NoStyle
            [ alignRight, paddingBottom 20 ]
            [ button NoStyle
                [ class "waves-effect waves-teal btn-flat" ]
                (text "Forgot Password?")
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
        , viewCreateProfile model
        ]


viewCreateProfile : Model -> Element.Element MyStyles variation Msg
viewCreateProfile model =
    let
        leftValue =
            if model.status == CreatingAccount then
                "0"
            else
                "-100%"
    in
        screen <|
            column Modal
                [ inlineStyle [ ( "left", leftValue ) ]
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
                    , row NoStyle [ center, width fill ] [ text "Create Profile" ]
                    ]
                , column WhiteBg
                    [ verticalCenter, spacing 20, padding 30, height fill ]
                    -- username Input
                    [ row NoStyle
                        [ verticalCenter, spacing 10 ]
                        [ materialIcon "account_circle" "green"
                        , email NoStyle
                            [ paddingLeft 10 ]
                            (Text UsernameEdited
                                model.usernameEntry
                                (placeholder { text = "Username" , label = hiddenLabel "" })
                                []
                            )
                        ]

                    --email input
                    , row NoStyle
                        [ verticalCenter, spacing 10 ]
                        [ materialIcon "mail" "green"
                        , email NoStyle
                            [ paddingLeft 10 ]
                            (Text EmailEdited
                                model.emailEntry
                                (placeholder { text = "Email" , label = hiddenLabel "" })
                                []
                            )
                        ]
                    , row NoStyle
                        [ verticalCenter, spacing 10 ]
                        [ materialIcon "lock" "green"
                        , currentPassword NoStyle
                            [ paddingLeft 10 ]
                            (Text PasswordEdited
                                model.passwordEntry
                                (placeholder { text = "Password" , label = hiddenLabel "" })
                                []
                            )
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
