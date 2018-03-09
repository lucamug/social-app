module ConversationListView exposing (..)

import Element exposing (..)
import Element.Background as Bg
import Color
import Misc exposing (onClickPreventDefault)
import Msgs exposing (LoggedInSubMsg(..))
import Element.Border as Border
import Dict

viewConversationListPanel myId convs =
    column
        []
        [ row
            [ height (px 100)
            , Bg.color Color.blue
            , Border.shadow 
                { offset = (0, 0)
                , blur = 15
                , size = 8 
                , color = Color.darkGray
                }
            ]
            [ el [ centerX ] <| text "TODO: conversation criteria" ]

        --  results list
        , column
            [ scrollbarY ]
            (List.map (viewConversationItem myId) <| Dict.toList convs)
        ]


viewConversationItem myId ( convId, conv ) =
    row
        [ height (px 80)
        , spacing 10
        , padding 15
        , htmlAttribute <| onClickPreventDefault (MessagesRequested convId)
        ]
        [ image
            [ height (px 45), width (px 45) ]
            { src = "images/default-profile-pic.png"
            , description = "Yo"
            }
        , conv.meta.members
            |> Dict.filter (\id member -> id /= myId)
            |> Dict.toList
            |> List.map (\( id, member ) -> member.username)
            |> String.join ", "
            |> text
        ]