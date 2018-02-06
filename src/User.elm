module User exposing (..)

import Json.Decode exposing(Decoder, string, nullable)
import Json.Decode.Pipeline exposing(decode, hardcoded, required)

type alias User =
    { id : String
    , username : String
    , photoUrl : Maybe String
    }

-----------Serialization---------------------

decoder =
    decode User
        |> required "id" string
        |> required "username" string
        |> required "photoUrl" (nullable string)