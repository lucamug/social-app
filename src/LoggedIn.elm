module LoggedIn exposing (..)

import Data exposing (..)
import Element exposing (Element, button, column, el, empty, html, row, screen, text, viewport)
import Element.Attributes exposing (..)
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Msgs exposing (..)
import Update exposing(update)
import Route exposing (Route(..))
import Styles exposing (MyStyles(..), stylesheet)


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
    let
        val =
            case model.route of
                Conversations ->
                    text "Conversations"

                Events ->
                    el NoStyle [ verticalCenter, center ] (text "Events")

                Wall ->
                    el NoStyle [ verticalCenter, center ] (text "Wall")

                People ->
                    el NoStyle [ verticalCenter, center ] (text "People")
    in
    el NoStyle [ height fill ] val


viewTab : Route -> Element MyStyles variation Msg
viewTab selectedRoute =
    let
        listTabs =
            [ ( "question_answer", Conversations )
            , ( "dns", Wall )
            , ( "search", People )
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
                [ width fill, height (px 50) ]
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
