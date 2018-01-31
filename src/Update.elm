module Update exposing (..)

import Data exposing (..)
import Navigation exposing (Location, modifyUrl)
import Ports exposing (login, logout)
import Messages exposing(..)
import Route exposing (Route, getRoute)
import Window

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CancelInput ->
            ( { model | auth = LoggedOut LoggingIn }, Cmd.none )

        EmailEdited email ->
            ( { model | email = email }, Cmd.none )

        PasswordEdited password ->
            ( { model | password = password }, Cmd.none )

        LogOutRequested ->
            ( model, logout "" )

        LogOutSuccess val ->
            ( { model | auth = LoggedOut LoggingIn }, Cmd.none )

        CreateProfileRequested ->
            ( { model | auth = LoggedOut CreatingAccount }, Cmd.none )

        LogInSuccess uid ->
            ( { model | auth = LoggedIn uid }, Cmd.none )

        LoginRequested ->
            ( model, login { email = model.email, password = model.password } )

        Resize viewportDims ->
            ( { model
                | viewportDims = viewportDims
              }
            , Cmd.none
            )

        ToRoute route ->
            ( model, modifyUrl (Route.routeToString route) )

        LocationChanged location ->
            let
                _ =
                    Debug.log "location changed: " location
            in
            ( { model | route = getRoute location }, Cmd.none )
