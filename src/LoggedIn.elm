module LoggedIn exposing (..)

import Data exposing (..)
import Element exposing (Element, button, column, el, empty, h1, html, row, screen, text, viewport)
import Element.Attributes exposing (..)
import Html
import List
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Msgs exposing (..)
import Route exposing (Route(..))
import Styles exposing (MyStyles(..), stylesheet)
import Update exposing (update)


viewLoggedIn : Model -> Element MyStyles variation Msg
viewLoggedIn model =
    column Main
        [ height fill, minHeight (percent 100), clip ]
        [ row NavBar
            []
            [ viewTab model.route
            , row NoStyle
                [ center
                , verticalCenter
                , width fill
                , onClickPreventDefault LogOutRequested
                ]
                [ materialIcon "settings" "black" ]
            ]
        , viewContent model
        ]


viewContent : Model -> Element MyStyles variation Msg
viewContent model =
    case model.route of
        Conversations ->
            text "Conversations"

        Events ->
            el NoStyle [ verticalCenter, center ] (text "Events")

        Wall ->
            el NoStyle [ verticalCenter, center ] (text "Wall")

        Search ->
                
            column NoStyle
                [ height fill
                , width fill
                ]
                -- search bar
                [ row YellowBar
                    [ height (px 100)
                    , center
                    , verticalCenter
                    ]
                    [ text "TODO: search criteria" ]

                --  results list
                , row NoStyle
                    [ height fill, width fill ]
                    [ column NoStyle
                        [ yScrollbar, width fill ]
                        (List.map
                            (\user ->

                                -- result item
                                row WhiteBg
                                    [ height (px 80)
                                    , width fill
                                    , verticalCenter
                                    , padding 15
                                    , onClickPreventDefault (CreateConversationRequested user.id)
                                    ]
                                    [ text user.username ]
                            )
                            model.users
                        )
                    ]
                ]


viewTab : Route -> Element MyStyles variation Msg
viewTab selectedRoute =
    let
        listTabs =
            [ ( "question_answer", Conversations )
            , ( "dns", Wall )
            , ( "search", Search )
            , ( "date_range", Events )
            ]

        indexRoute =
            List.map Tuple.second listTabs
                |> elemIndex selectedRoute
    in
    Element.map RouteChangeRequested
        (column NoStyle
            [ width (fillPortion 4) ]
            [ row NoStyle
                [ width fill
                , height (px 50)
                ]
                (List.map viewTabButton listTabs)
            , viewTabUnderline (Maybe.withDefault 0 indexRoute) (List.length listTabs)
            ]
        )


viewTabUnderline : Int -> Int -> Element MyStyles variation msg
viewTabUnderline index length =
    let
        barWidth =
            100 / toFloat length
    in
    row Underline
        [ width fill
        , height (px 2)
        ]
        [ el Pusher [ width (percent (toFloat index * barWidth)) ] empty
        , el YellowBar [ width (percent barWidth) ] empty
        ]


viewTabButton : ( String, Route ) -> Element MyStyles variation Route
viewTabButton ( iconName, route ) =
    row NoStyle
        [ width (fillPortion 1)
        , onClickPreventDefault route
        , center
        , verticalCenter
        ]
        [ materialIcon iconName "black" ]
