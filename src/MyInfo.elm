module MyInfo exposing (..)

import Json.Decode exposing (Decoder, string, map2, field, decodeValue)
import User exposing (User)


type alias MyInfo =
    { myUserId : String
    , myUserInfo : User
    }

decoder =
    decodeValue
            <| map2
            (\id info -> { myUserId = id, myUserInfo = info })
            (field "myUserId" string)
            (field "myUserInfo" User.decoder)
        
