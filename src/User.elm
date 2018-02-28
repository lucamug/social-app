module User exposing (..)

import Json.Decode exposing (Decoder, string, nullable)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)


type alias User =
    { username : String
    , photoUrl : Maybe String
    }





-----------Serialization---------------------


decoder =
    decode User
        |> required "username" string
        |> required "photoUrlCouple" (nullable string)
