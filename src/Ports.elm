port module Ports exposing (..)

import Json.Decode as De


-- To Javascript
port newUser : { username : String, email : String, password : String } -> Cmd msg
port login : { email : String, password : String } -> Cmd msg
port logout : () -> Cmd msg
port createConversation : String -> Cmd msg  -- arg:  otherUserId
port sendMessage: {convId: String, text: String, image: String} -> Cmd msg
port listenToConvMetas: () -> Cmd msg
port listenToMessages: String -> Cmd msg
port stopListeningToMessages: () -> Cmd msg
port getAllOtherUsers : () -> Cmd msg
port initSidenav: () -> Cmd msg
port openSidenav: () -> Cmd msg

-- To Elm
port loggedIn : (De.Value -> msg) -> Sub msg
port loggedOut : (() -> msg) -> Sub msg
port usersReceived : (De.Value -> msg) -> Sub msg
port convsMetaReceived : (De.Value -> msg) -> Sub msg
port messagesReceived: (De.Value -> msg) -> Sub msg