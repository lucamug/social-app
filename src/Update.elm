module Update exposing (..)

import Data exposing (..)
import Navigation exposing (Location, modifyUrl)
import Ports exposing (login, logout, newUser, createConversation)
import Msgs exposing(..)
import Route exposing (Route, getRoute, getRouteData)
import User
import Result
import Json.Decode exposing(list, decodeValue)

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


        ProfileFormRequested ->
            ( { model | auth = LoggedOut CreatingAccount }, Cmd.none )


        WindowResized viewportDims ->
            ( { model
                | viewportDims = viewportDims
              }
            , Cmd.none
            )

        ---- URL Request and change

        RouteChangeRequested route ->
            ( model, modifyUrl (Route.routeToString route) )

        LocationChanged location ->
            let
                _ =
                    Debug.log "location changed: " location
                route = getRoute location
            in
            ( { model | route = route}, getRouteData route)

        ------ PORT OUTGOING REQUEST MESSAGES -----------------------

        SubmitProfileRequested ->
            ( model, newUser { username = model.usernameEntry, email = model.emailEntry, password = model.passwordEntry } ) 
 

        LoginRequested ->
            ( model, login { email = model.emailEntry, password = model.passwordEntry } )
        
        LogOutRequested ->
            ( model, logout "" )
        

        ------ PORT SUBSCRIPTIONS MESSAGES --------------------------

        LoginSucceeded uid ->
            ( { model | auth = LoggedIn, uid = Just uid }, Cmd.none )

        LogOutSucceeded val ->
            ( { model | auth = LoggedOut LoggingIn }, Cmd.none )

        UsersReceived usersJson ->
            ( {model | users = Result.withDefault 
            [] (decodeValue (list User.decoder) usersJson) }, Cmd.none )

        CreateConversationRequested userId ->

            let
                _ = Debug.log "wassup" userId
            in
                
            ( model, Cmd.none)
