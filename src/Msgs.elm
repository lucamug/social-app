module Msgs exposing (..)

import Json.Decode as De
import Dom exposing (Error)
import Window
import Navigation exposing (Location, modifyUrl)

type Msg
    = NoOp
    | WindowResized Window.Size
    | LogErr String
    | LocationChanged Location
    | LoginSuccessful De.Value
    | LogoutSuccessful ()
    | LoggedOutMsg LoggedOutSubMsg
    | LoggedInMsg LoggedInSubMsg

type LoggedInSubMsg
    = OpenSidenavRequested
    | CloseSidenavRequested
    | MessagesRequested String
    | MessagesCancelRequested
    | CreateConversationRequested String
    | SendMessageRequested String { rows : Int, textInput : String } String
    | TabRequested TabBarTab
    | LogOutRequested
    | UsersReceived De.Value
    | ConvsMetaReceived De.Value
    | MessagesReceived De.Value
    | MessagesScrolled (Result Error ())
    | AutoExpandInput String { textValue : String, rows : Int }


type LoggedOutSubMsg
    = SubmitProfileRequested
    | EmailEdited String
    | PasswordEdited String
    | UsernameEdited String
    | ProfileCreationCanceled
    | ProfileFormRequested
    | LoginRequested


type TabBarTab
    = Conversations
    | Events
    | Wall
    | Search
