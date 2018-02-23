module Conversation exposing (..)

import Message exposing (Message)
import User exposing (User)
import Json.Decode exposing (Decoder, string, nullable, list)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Message exposing (..)


type alias Conversation =
    { id : String
    , ownerId : String
    , members : List User
    , lastMessage : Maybe Message
    }


-----------Serialization---------------------


decoder : Decoder Conversation
decoder =
    decode Conversation
        |> required "id" string
        |> required "conversationOwner" string
        |> required "members" (list User.decoder)
        |> required "lastMessage" (nullable Message.decoder)



-- viewConversationList : Element MyStyles variation Msg
-- viewConversationList =
--     let
--         conversations =
--             [ Conversation "bb84r6" "xrere" [ "dude" ] (Message "serrerkj" "WassupDude" 4438834) ]
--     in
--     column NoStyle [ height fill, scrollbars ] (List.map viewConversationRow conversations)

-- viewConversationRow : Conversation -> Element MyStyles variation Msg
-- viewConversationRow conversation =
--     row NoStyle
--         [ height (px 80), width fill, padding 5, spacing 5, onClickPreventDefault (OpenConversation conversation.id) ]
--         [ image Avatar [ height (px 40), width (px 40), verticalCenter ] { src = "images/default-profile-pic.png", caption = "yo" }
--         , el NoStyle [ center, verticalCenter ] (Element.text conversation.id)
--         ]