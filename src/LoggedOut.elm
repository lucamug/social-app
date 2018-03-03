module LoggedOut exposing (..)

import Element exposing (..)
import Element.Input exposing (currentPassword, email, button, placeholder, labelLeft, username)
import Element.Background as Bg
import Element.Border as Border
import Element.Font as Font
import Color exposing (rgb, rgba)
import Html
import Html.Attributes exposing (class, style)
import Ports
import Misc exposing (materialIcon, onClickPreventDefault)


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


viewLoggedOut model =
    column
        [ htmlAttribute (class "green lighten-2")
        , padding 50
        , spacing 10
        , Bg.color (rgb 102 187 106)
        , inFront (viewCreateProfile model)
        ]
        -- Title
        [ el
            [ centerX ]
            (html
                (Html.h1 []
                    [ Html.text "2 Of Us" ]
                )
            )

        -- Email Input
        , row
            [ ]
            [ email
                [ alignLeft
                , Bg.color (rgb 102 187 106)
                ]
                { onChange = Just EmailEdited
                , text = model.emailEntry
                , placeholder = Just (placeholder [] (text "Email"))
                -- , label = labelLeft [ centerY ] (materialIcon "mail" "green")
                , label = labelLeft [ centerY ] (materialIcon "mail" "green")
                }
            ]

        -- Password Input
        , row
            []
            [ currentPassword
                [ alignLeft]
                { onChange = Just PasswordEdited
                , text = model.passwordEntry
                , placeholder = Just (placeholder [] (text "Password"))
                , label = labelLeft [ centerY ] (materialIcon "lock" "green")
                , show = False
                }
            ]

        -- Forgot password button
        , row
            []
            [ button
                [ htmlAttribute <| class "waves-effect waves-teal btn-flat"
                , alignRight
                ]
                { onPress = Nothing
                , label = text "Forgot Password?"
                }
            ]

        -- Login Button
        , row
            [ paddingXY 0 30 ]
            [ button
                [ width fill
                , htmlAttribute <| class "waves-effect waves-light btn red"
                , Font.color <| rgb 0 0 0
                , Border.rounded 8
                ]
                { onPress = Just LoginRequested
                , label = text "Log In"
                }
            ]

        -- Create Free Profile Button
        , row
            [ paddingXY 0 30 ]
            [ button
                [ width (px 250)
                , centerX
                , htmlAttribute <| class "waves-effect waves-light btn"
                , Font.color <| rgb 255 255 255
                , Border.rounded 8
                ]
                { onPress = Just ProfileFormRequested
                , label = text "Create free profile"
                }
            ]
        ]


viewCreateProfile model =
    let
        leftValue =
            if model.status == CreatingAccount then
                "0"
            else
                "100%"
    in
        column
            [ htmlAttribute
                (style
                    [ ( "transition", "left 130ms ease-in" )
                    , ( "left", leftValue )
                    ]
                )
            , Bg.color <| rgb 255 255 255
            ]
            [ row
                [ height (px 60)
                , padding 10
                ]
                [ row 
                    [ width (px 40)
                    , Bg.color Color.red
                    , Border.rounded 10
                    , htmlAttribute (onClickPreventDefault ProfileCreationCanceled)
                    ]
                    [materialIcon "chevron_left" "white"]
                , row [] [ el [centerX] <| text "Create Profile" ]
                ]
            , column
                [ spacing 20, padding 30 ]
                -- username Input
                [ row [height (px 100)] [empty]
                , row
                    []
                    [ username
                        [ alignLeft, padding 10 ]
                        { onChange = Just UsernameEdited
                        , text = model.usernameEntry
                        , placeholder = Just <| placeholder [] (text "Username")
                        , label = labelLeft [centerY] (materialIcon "account_circle" "green")
                        }
                    ]

                --email input
                , row
                    []
                    [ email
                        [ alignLeft, padding 10 ]
                        { onChange = Just EmailEdited
                        , text = model.emailEntry
                        , placeholder = Just <| placeholder [] (text "Email")
                        , label = labelLeft [ centerY ] (materialIcon "mail" "green")
                        }
                    ]

                -- password input
                , row
                    []
                    [ currentPassword
                        [ alignLeft, padding 10 ]
                        { onChange = Just PasswordEdited
                        , text = model.passwordEntry
                        , placeholder = Just <| placeholder [] (text "Password")
                        , label = labelLeft [ centerY ] (materialIcon "lock" "green")
                        , show = False
                        }
                    ]

                -- Login Button
                , row
                    [padding 30 ]
                    [ button
                        [ width fill
                        , htmlAttribute <| class "waves-effect waves-light btn red"
                        ]
                        { onPress = Just SubmitProfileRequested
                        , label = text "Create Profile"
                        }
                    ]
                ]
            ]
