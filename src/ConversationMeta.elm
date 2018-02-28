module ConversationMeta exposing (..)

import Message exposing (Message)
import User exposing (User)
import Json.Decode exposing (Decoder, string, nullable, dict)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Message exposing (..)
import Dict exposing (Dict)


type alias ConversationMeta =
    { ownerId : String
    , members : Dict String User
    , lastMessage : Maybe Message
    }


-----------Serialization---------------------


decoder : Decoder ConversationMeta
decoder =
    decode ConversationMeta
        |> required "conversationOwner" string
        |> required "members" (dict User.decoder)
        |> required "lastMessage" (nullable Message.decoder)


-- viewConversationList : Element MyStyles variation Msg
-- viewConversationList =
--     let
--         conversations =
--             [ ConversationMeta "bb84r6" "xrere" [ "dude" ] (Message "serrerkj" "WassupDude" 4438834) ]
--     in
--     column NoStyle [ height fill, scrollbars ] (List.map viewConversationRow conversations)

-- viewConversationRow : ConversationMeta -> Element MyStyles variation Msg
-- viewConversationRow conversation =
--     row NoStyle
--         [ height (px 80), width fill, padding 5, spacing 5, onClickPreventDefault (OpenConversation conversation.id) ]
--         [ image Avatar [ height (px 40), width (px 40), verticalCenter ] { src = "images/default-profile-pic.png", caption = "yo" }
--         , el NoStyle [ center, verticalCenter ] (Element.text conversation.id)
--         ]