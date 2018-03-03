module Main exposing (view)

import LoggedOut exposing (viewLoggedOut)
import LoggedIn
import Element exposing (..)
import Ports
import User exposing (User)
import MyInfo exposing (MyInfo)
import Json.Decode as De
import Html
import Window
import Navigation exposing (Location, modifyUrl)
import Route exposing (Route, getRoute, fetchRouteData)


type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , route : Route
    }


init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    { viewportDims = flags
    , auth = AwaitingAuth
    , route = Route.getRoute location
    }
        ! []


type Auth
    = LoggedIn LoggedIn.Model
    | LoggedOut LoggedOut.Model
    | AwaitingAuth


type Msg
    = NoOp
    | WindowResized Window.Size
    | LogErr String
    | LocationChanged Location
    | LoginSuccessful De.Value
    | LogoutSuccessful ()
    | LoggedOutMsg LoggedOut.Msg
    | LoggedInMsg LoggedIn.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        LogErr err ->
            model ! []

        LoggedOutMsg subMsg ->
            case model.auth of
                LoggedOut subModel ->
                    let
                        ( newSubModel, cmd ) =
                            LoggedOut.update subMsg subModel
                    in
                        { model | auth = LoggedOut newSubModel } ! [ cmd ]

                _ ->
                    model ! []

        LoggedInMsg subMsg ->
            case model.auth of
                LoggedIn subModel ->
                    let
                        ( newSubModel, cmd ) =
                            LoggedIn.update subMsg subModel
                    in
                        { model | auth = LoggedIn newSubModel } ! [ cmd ]

                _ ->
                    model ! []

        WindowResized viewportDims ->
            { model | viewportDims = viewportDims } ! []

        -- URL Request and change
        LocationChanged location ->
            let
                route =
                    getRoute location

                cmd =
                    case model.auth of
                        LoggedIn subModel ->
                            fetchRouteData route

                        _ ->
                            Cmd.none
            in
                { model | route = route } ! [ cmd ]

        ------ PORT SUBSCRIPTIONS MESSAGES --------------------------
        LogoutSuccessful () ->
            { model | auth = LoggedOut LoggedOut.initialModel } ! []

        LoginSuccessful userValues ->
            { model
                | auth =
                    LoggedIn
                        (LoggedIn.initialModel
                            (Result.withDefault (MyInfo "" (User "" Nothing)) <| MyInfo.decoder userValues
                            )
                        )
            }
                ! [ Route.fetchRouteData model.route
                  , Ports.initSidenav ()
                  ]



------------VIEW-----------------------------------------------


view : Model -> Html.Html Msg
view model =
    layout [width fill, height fill] <|
        let
            mainView =
                case model.auth of
                    LoggedOut subModel ->
                        Element.map LoggedOutMsg (viewLoggedOut subModel)

                    LoggedIn subModel ->
                        Element.map LoggedInMsg (LoggedIn.viewLoggedIn subModel)

                    AwaitingAuth ->
                        text "awaiting"
        in
            column 
                [ height fill ]
                [ mainView
                ]



------------- SUBSCRIPTIONS --------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes WindowResized
        , Ports.usersReceived (LoggedInMsg << LoggedIn.UsersReceived)
        , Ports.convsMetaReceived (LoggedInMsg << LoggedIn.ConvsMetaReceived)
        , Ports.messagesReceived (LoggedInMsg << LoggedIn.MessagesReceived)
        , Ports.loggedIn LoginSuccessful
        , Ports.loggedOut LogoutSuccessful
        ]


main : Program { height : Int, width : Int } Model Msg
main =
    Navigation.programWithFlags
        LocationChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
