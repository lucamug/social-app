module ConversationView exposing (viewConversationPanel)

import Msgs exposing (LoggedInSubMsg(..))
import Misc exposing (..)
import Element exposing (..)
import Html.Attributes exposing (class, style, rows, placeholder, src)
import Html exposing (textarea)
import Json.Decode exposing (..)
import Html.Events exposing (on)
import Html.Attributes as Attr
import Element.Background as Bg
import Element.Border as Border
import Element.Font as Font
import Dom
import Color exposing (rgb)
import Dict
import String exposing (padLeft)
import Date exposing (hour, minute)


viewConversationPanel ( convId, conv ) myUserId =
    let
        otherMembers =
            (conv.meta.members
                |> Dict.toList
                |> List.filter (\( memId, member ) -> memId /= myUserId)
                |> List.map (\( memId, member ) -> member.username)
                |> String.join ", "
            )
    in
        column
            [ Bg.color Color.white, htmlAttribute <| style [ ( "max-height", "100vh" ) ] ]
            [ row
                [ height (px 60)
                , padding 10
                , Bg.color Color.darkGrey
                , alignLeft
                ]
                [ el
                    [ width (px 40)
                    , htmlAttribute <| onClickPreventDefault MessagesCancelRequested
                    ]
                    (materialIcon "chevron_left" "black")
                , row
                    [ centerX
                    ]
                    [ text otherMembers ]
                ]
            , column
                [ scrollbarY
                , Bg.color Color.lightGray
                , htmlAttribute <| Attr.id convId
                ]
                (List.map (viewMessageLine myUserId) conv.messages)

            -- , viewTextInput model
            , viewMessageInput convId conv.extras
            ]


viewMessageInput convId extras =
    let
        _ =
            Debug.log "sh" extras.rows
    in
        row []
            [ el [ width fill, padding 8 ]
                (html <|
                    textarea
                        [ style
                            [ ( "width", "100%" )
                            , ( "max-width", "100%" )
                            , ( "border", "none" )
                            , ( "outline", "none" )
                            , ( "resize", "none" )
                            , ( "box-shadow", "none" )
                            ]
                        , rows extras.rows
                        , Html.Attributes.value extras.textInput
                        , placeholder "Write a message"
                        , on "input" (inputDecoder convId)
                        ]
                        []
                )
            , el
                [ width (px 30)
                , htmlAttribute <| onClickPreventDefault (SendMessageRequested convId extras "")
                ]
                (materialIcon "send" "blue")
            ]


inputDecoder convId =
    map2 (\t s -> AutoExpandInput convId { textValue = t, rows = min 10 (2 + ceiling ((toFloat (s - 35)) / 16)) })
        (at [ "target", "value" ] string)
        (at [ "target", "scrollHeight" ] int)


viewMessageLine myUserId message =
    let
        ts =
            Date.fromTime (message.timestamp * 1000)

        timeString =
            (ts
                |> hour
                |> (flip rem) 12
                |> (\hr ->
                        if hr == 0 then
                            12
                        else
                            hr
                   )
                |> toString
            )
                ++ ":"
                ++ (ts |> minute |> toString |> padLeft 2 '0')
                ++ (if (hour ts) < 12 then
                        "am"
                    else
                        "pm"
                   )
    in
        column
            [ alignTop
            , height shrink
            , htmlAttribute <| Html.Attributes.id (toString message.id)
            ]
            [ row [ height (px 3), Bg.color Color.blue ] [ empty ]
            , row
                [ padding 6
                ]
                -- User Image
                [ (el [ width (px 65), paddingXY 10 0 ]
                    (if message.isNewSender && message.userId /= myUserId then
                        html <|
                            Html.img
                                [ src "images/default-profile-pic.png"
                                , style [ ( "border-radius", "100px" ), ( "width", "45px" ) ]
                                ]
                                []
                     else
                        empty
                    )
                  )

                -- text box
                , el [ width fill ]
                    (paragraph
                        [ Border.rounded 5
                        , Bg.color Color.white
                        , if message.userId /= myUserId then
                            alignLeft
                          else
                            alignRight
                        , Border.color Color.darkGray
                        , Border.width 1
                        , paddingEach { bottom = 8, left = 8, right = 8, top = 4 }
                        ]
                        [ el
                            [ Font.size 14
                            , htmlAttribute <|
                                style
                                    [ ( "overflow-wrap", "break-word" )
                                    , ( "word-break", "break-word" )
                                    ]
                            ]
                            (text message.content)
                        , el [ width (px 4) ] empty
                        , el [ Font.size 10, Font.color Color.darkGray ] (text timeString)
                        ]
                    )
                ]
            ]
