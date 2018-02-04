port module Ports exposing (..)

-- To Javascript
port newUser : {username: String, email: String, password: String} -> Cmd msg
port login   : {email: String, password: String} -> Cmd msg
port logout   : String -> Cmd msg


-- To Elm
port loggedIn : (String -> msg) -> Sub msg
port loggedOut : (String -> msg) -> Sub msg

