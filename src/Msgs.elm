module Msgs exposing (..)

import Json.Decode as De

type LoggedInSubMsg
    = OpenSidenavRequested
    | CloseSidenavRequested
    | MessagesRequested String
    | MessagesCancelRequested
    | CreateConversationRequested String
    | TabRequested TabBarTab
    | LogOutRequested
    | UsersReceived De.Value
    | ConvsMetaReceived De.Value
    | MessagesReceived De.Value
    | AutoExpandInput { textValue : String, rows : Int }


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
