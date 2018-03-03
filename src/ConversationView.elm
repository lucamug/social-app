module ConversationView exposing (viewConversationsPanel)

import Element exposing (..)
import Dict exposing (Dict)

viewConversationsPanel myId convMetas =
    column
        []
        -- search bar
        [ row
            [ height (px 100)
            , Bg.color Color.blue
            ]
            [ el [ centerX ] <| text "TODO: conversation criteria" ]

        --  results list
        , column
            [ scrollbarY ]
            (List.map (viewConversationItem myId) <| Dict.toList convMetas)
        ]


viewConversationItem myId ( convId, convMeta ) =
    row
        [ height (px 80)
        , spacing 10
        , padding 15
        , htmlAttribute <| onClickPreventDefault (ViewConversationRequested convId)
        ]
        [ image
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , description = "Yo"
            }
        , convMeta.members
            |> Dict.filter (\id member -> id /= myId)
            |> Dict.toList
            |> List.map (\( id, member ) -> member.username)
            |> String.join ", "
            |> text
        ]