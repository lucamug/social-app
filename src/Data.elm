module Data exposing (..)

import Route exposing (Route)
import Navigation exposing(Location)
import Msgs exposing(..)

type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , route : Route
    , usernameEntry: String
    , emailEntry: String
    , passwordEntry : String
    }

init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    ( { viewportDims = flags
      , auth = LoggedOut LoggingIn
      , route = Route.getRoute location
      , usernameEntry = ""
      , emailEntry = ""
      , passwordEntry = ""
      }
    , Cmd.none
    )



type RouteData
    = LoggedOutData


type ViewData
    = LogInData


type Auth
    = LoggedIn String
    | LoggedOut LoggedOutStatus
    | AwaitingAuth


type LoggedOutStatus
    = LoggingIn 
    | CreatingAccount
    | RetrievingPassword
