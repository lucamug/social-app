module Update exposing (..)

import Data exposing (..)
import Navigation exposing (Location, modifyUrl)
import Ports exposing (login, logout, newUser)
import Msgs exposing(..)
import Route exposing (Route, getRoute)
import Window

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ProfileCreationCanceled ->
            ( { model | auth = LoggedOut LoggingIn }, Cmd.none )

        EmailEdited email ->
            ( { model | emailEntry = email }, Cmd.none )

        PasswordEdited password ->
            ( { model | passwordEntry = password }, Cmd.none )

        UsernameEdited username ->
            ( { model | usernameEntry = username }, Cmd.none )

        LogOutRequested ->
            ( model, logout "" )

        LogOutSucceeded val ->
            ( { model | auth = LoggedOut LoggingIn }, Cmd.none )

        CreateProfileRequested ->
            ( { model | auth = LoggedOut CreatingAccount }, Cmd.none )

        SubmitProfileRequested ->
            ( model, newUser { username = model.usernameEntry, email = model.emailEntry, password = model.passwordEntry } ) 
 
        LoginSucceeded uid ->
            ( { model | auth = LoggedIn uid }, Cmd.none )

        LoginRequested ->
            ( model, login { email = model.emailEntry, password = model.passwordEntry } )

        WindowResized viewportDims ->
            ( { model
                | viewportDims = viewportDims
              }
            , Cmd.none
            )

        RouteChangeRequested route ->
            ( model, modifyUrl (Route.routeToString route) )

        LocationChanged location ->
            let
                _ =
                    Debug.log "location changed: " location
            in
            ( { model | route = getRoute location }, Cmd.none )
