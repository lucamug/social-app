module Data exposing (..)

import Route exposing (Route)
import User exposing(User)
import Navigation exposing(Location)
import Msgs exposing(..)

type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , uid : Maybe String
    , route : Route
    , usernameEntry: String
    , users: List User
    , emailEntry: String
    , passwordEntry : String
    }

init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        route = Route.getRoute location
    in
        
    ( { viewportDims = flags
    --   , auth = LoggedOut LoggingIn
      , auth = AwaitingAuth
      , route = route
      , uid = Nothing
      , usernameEntry = ""
      , users = []
      , emailEntry = ""
      , passwordEntry = ""
      }
    , Route.getRouteData route
    )





type RouteData
    = LoggedOutData


type ViewData
    = LogInData


type Auth
    = LoggedIn
    | LoggedOut LoggedOutStatus
    | AwaitingAuth


type LoggedOutStatus
    = LoggingIn 
    | CreatingAccount
    | RetrievingPassword
