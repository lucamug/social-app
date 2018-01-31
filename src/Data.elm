module Data exposing (..)

import Route exposing (Route)
import Navigation exposing(Location)
import Messages exposing(..)


type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , route : Route
    , email : String
    , password : String
    }

init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    ( { viewportDims = flags
      , auth = LoggedOut LoggingIn
      , email = ""
      , password = ""
      , route = Route.getRoute location
      }
    , Cmd.none
    )


type Auth
    = LoggedIn String
    | LoggedOut LoggedOutStatus
    | AwaitingAuth

--  ❤😍🐱‍👓
type LoggedOutStatus
    = LoggingIn 
    | CreatingAccount
    | RetrievingPassword
