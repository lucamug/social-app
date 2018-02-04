module Msgs exposing(..)
import Window
import Navigation exposing(Location)
import Route exposing(Route)

type Msg
    = NoOp
    | EmailEdited String
    | PasswordEdited String
    | UsernameEdited String
    | WindowResized Window.Size
    | LoginRequested
    | LoginSucceeded String
    | ProfileCreationCanceled
    | LogOutSucceeded String
    | LogOutRequested
    | CreateProfileRequested
    | SubmitProfileRequested
    | LocationChanged Location
    | RouteChangeRequested Route