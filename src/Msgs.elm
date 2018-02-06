module Msgs exposing(..)
import Window
import User exposing(User)
import Navigation exposing(Location)
import Route exposing(Route)
import Json.Decode

type Msg
    = NoOp

    | EmailEdited String
    | PasswordEdited String
    | UsernameEdited String

    | WindowResized Window.Size


    | ProfileCreationCanceled
    | ProfileFormRequested

-- Url Changes
    | RouteChangeRequested Route
    | LocationChanged Location

-- OUTGOING PORT REQUESTS
    | LoginRequested
    | LogOutRequested
    | CreateConversationRequested String
    | SubmitProfileRequested

-- INCOMING PORT MESSAGES
    | LoginSucceeded String
    | LogOutSucceeded String
    | UsersReceived (Json.Decode.Value)
