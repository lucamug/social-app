module Conversation exposing (..)

import Message exposing (Message)
import User exposing (User)
import Json.Decode exposing (Decoder, string, nullable, dict)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Message exposing (..)
import Dict exposing (Dict)

type alias Conversation =
    { meta: ConversationMeta
    , messages: List Message
    , extras: {rows: Int, textInput: String}
    }

type alias ConversationMeta =
    { ownerId : String
    , members : Dict String User
    , lastMessage : Maybe Message
    }


-----------Serialization---------------------


convMetaDecoder : Decoder ConversationMeta
convMetaDecoder =
    decode ConversationMeta
        |> required "conversationOwner" string
        |> required "members" (dict User.decoder)
        |> required "lastMessage" (nullable Message.decoder)
