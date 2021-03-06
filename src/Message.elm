module Message exposing (..)

import Json.Decode exposing(Decoder, string, float, bool)
import Json.Decode.Pipeline exposing(decode, hardcoded, required)
import Time exposing (Time)


type alias Message =
    { id: String
    , userId : String
    , bundleId: String
    , content : String
    , timestamp : Time
    , isNewDay: Bool
    , isNewSender: Bool
    }

decoder =
    decode Message
        |> required "id" string
        |> required "userId" string
        |> required "bundleId" string
        |> required "content" string
        |> required "timestamp" float
        |> required "isNewDay" bool
        |> required "isNewSender" bool
