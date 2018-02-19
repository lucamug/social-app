module Message exposing (..)

import Json.Decode exposing(Decoder, string, float)
import Json.Decode.Pipeline exposing(decode, hardcoded, required)
import Time exposing (Time)


type alias Message =
    { userId : String
    , content : String
    , timestamp : Time
    }

decoder =
    decode Message
        |> required "userId" string
        |> required "content" string
        |> required "timestamp" float
