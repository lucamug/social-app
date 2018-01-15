module Msgs exposing (..)

import Navigation exposing (Location)
import Route exposing (Route)
import Window

type Msg
    = NoOp
    | EmailEdited String
    | PasswordEdited String
    | Resize Window.Size
    | LoginRequested
    | LogInSuccess String
    | LogOutSuccess String
    | UserId String
    | LogOutRequested
    | LocationChanged Location
    | ToRoute Route
