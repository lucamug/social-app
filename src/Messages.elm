module Messages exposing(..)
import Window
import Navigation exposing(Location)
import Route exposing(Route)

type Msg
    = NoOp
    | EmailEdited String
    | PasswordEdited String
    | Resize Window.Size
    | LoginRequested
    | LogInSuccess String
    | CancelInput
    | LogOutSuccess String
    | LogOutRequested
    | CreateProfileRequested
    | LocationChanged Location
    | ToRoute Route