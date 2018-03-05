module ConversationView exposing (viewConversationPanel)

import Msgs exposing (LoggedInSubMsg(..))
import Misc exposing (..)
import Element exposing (..)
import Dict exposing (Dict)
import Html.Attributes exposing (class, style, rows, placeholder)
import Html exposing (textarea)
import Json.Decode exposing (..)
import Html.Events exposing (on)
import Element.Background as Bg
import Color exposing (rgb)

viewConversationPanel model =
    let
        rightValue =
            case model.activeConversation of
                Nothing ->
                    "100%"

                Just convId ->
                    "0"
            

        messages =
            case model.activeConversation of
                Nothing ->
                    []

                Just convId ->
                    case Dict.get convId model.conversationMessages of
                        Nothing ->
                            []

                        Just messages ->
                            messages
    in
        column
            [ htmlAttribute <|
                style
                    [ ( "transition", "left 130ms ease-in" )
                    , ( "left", rightValue )
                    ]
            , Bg.color Color.white
            ]
            [ row
                [ height (px 60)
                , padding 10
                , alignLeft
                ]
                [ row [ centerX ] [ text "Conversation" ]
                , el
                    [ htmlAttribute <| class "btn-floating waves-effect btn-flat red"
                    , width (px 40)
                    , htmlAttribute <| onClickPreventDefault MessagesCancelRequested
                    ]
                    (materialIcon "chevron_right" "black")
                ]
            , column
                [ spacing 20, padding 30 ]
                (List.map (viewMessageLine model.me.myUserId) messages)

            -- , viewTextInput model
            , row [] [viewMessageInput 4]
            ]

viewMessageInput numRows =
    html <|
        textarea
            [ style
                [ ( "width", "100%" )
                , ( "border", "none" )
                , ( "outline", "none" )
                , ( "box-shadow", "none" )
                ]
            , rows numRows
            , placeholder "Type a message"
            , on "input" inputDecoder
            ]
            []


inputDecoder =
    map2 (\t r -> AutoExpandInput { textValue = t, rows = ceiling ((toFloat (r-52))/21)})
        (at [ "target", "value" ] string)
        (at [ "target", "scrollHeight" ] int)
        

viewMessageLine myUserId message =
    row [] [ text message.content ]


