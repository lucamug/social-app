module Msgs exposing (..)

import Navigation exposing (Location)
import Route exposing (Route)
import Window

type Msg
    = NoOp
    | UsernameAdded String
    | Resize Window.Size
    | LogInRequested
    | LogOutRequested
    | LocationChanged Location
    | ToRoute Route
    | FinishedAuth (Result String ())
