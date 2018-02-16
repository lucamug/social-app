module Main exposing (view)

import LoggedOut exposing (viewLoggedOut)
import LoggedIn exposing (viewLoggedIn, Msg(..))
import Styles exposing (MyStyles(NoStyle), stylesheet)
import Element exposing (..)
import Element.Attributes exposing (..)
import Ports
import Json.Decode as De
import Html
import Window
import Navigation exposing (Location, modifyUrl)
import Route exposing (Route, getRoute, fetchRouteData)


-- import Msgs exposing (..)


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
    | LoginSuccessful ()
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

        LoginSuccessful () ->
            { model | auth = LoggedIn LoggedIn.initialModel }
                ! [ Route.fetchRouteData model.route
                  , Ports.initSidenav ()
                  ]



------------VIEW-----------------------------------------------


view : Model -> Html.Html Msg
view model =
    viewport stylesheet <|
        let
            mainView =
                case model.auth of
                    LoggedOut subModel ->
                        Element.map LoggedOutMsg (viewLoggedOut subModel)

                    LoggedIn subModel ->
                        Element.map LoggedInMsg (viewLoggedIn subModel model.route)

                    AwaitingAuth ->
                        text "awaiting"
        in
            column NoStyle
                [ height fill ]
                [ mainView
                ]



------------- SUBSCRIPTIONS --------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes WindowResized

        -- , Ports.getInfoFromOutside
        , Ports.usersReceived (LoggedInMsg << UsersReceived)
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
