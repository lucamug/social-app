port module Ports exposing (..)

import Json.Decode
import User exposing (User)

-- To Javascript
port newUser : {username: String, email: String, password: String} -> Cmd msg
port login   : {email: String, password: String} -> Cmd msg
port logout   : String -> Cmd msg
port createConversation: {myUserId: String, otherUserId: String} -> Cmd msg
port getAllUsers: Bool -> Cmd msg


-- To Elm
port loggedIn : (String -> msg) -> Sub msg
port loggedOut : (String -> msg) -> Sub msg
port usersReceived: (Json.Decode.Value -> msg) -> Sub msg
