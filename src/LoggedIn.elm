module LoggedIn exposing (..)

import Element exposing (Element, toHtml, image, button, column, el, empty, h1, html, row, screen, text, viewport)
import Route exposing (..)
import Element.Attributes exposing (..)
import List
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Styles exposing (MyStyles(..), stylesheet)
import Navigation exposing (modifyUrl)
import Json.Decode as De exposing (decodeValue)
import Ports
import User exposing (User)
import Conversation exposing (Conversation)


type alias Model =
    { users : List User
    , conversations : List Conversation
    , menu : Bool
    }


initialModel : Model
initialModel =
    { users = []
    , conversations = []
    , menu = False
    }


type Msg
    = OpenSidenavRequested
    | CloseSidenavRequested
    | CreateConversationRequested String
    | RouteChangeRequested Route
    | LogOutRequested
    | UsersReceived De.Value


update msg model =
    case msg of
        OpenSidenavRequested ->
            { model | menu = True } ! []

        CloseSidenavRequested ->
            { model | menu = False } ! []

        CreateConversationRequested userId ->
            model
                ! [ Ports.createConversation userId
                  , modifyUrl <| "conversations"
                  ]

        RouteChangeRequested route ->
            model ! [ modifyUrl <| Route.routeToString route ]

        LogOutRequested ->
            model ! [ Ports.logout () ]

        UsersReceived usersValue ->
            { model | users = Result.withDefault [] <| decodeValue (De.list User.decoder) usersValue } ! []


viewLoggedIn : Model -> Route -> Element MyStyles variation Msg
viewLoggedIn model route =
    column Main
        [ height fill, minHeight (percent 100), clip ]
        [ viewContent model route
        , row NavBar
            []
            [ viewTab route
            , row NoStyle
                [ center
                , verticalCenter
                , width fill
                , onClickPreventDefault OpenSidenavRequested
                ]
                [ materialIcon "menu" "dark" ]
            ]
        , viewSidenav model
        ]


viewContent : Model -> Route -> Element MyStyles variation Msg
viewContent model route =
    el NoStyle [height fill, width fill](
    case route of
        Conversations ->
            viewConversationsPanel model.users

        Events ->
            el NoStyle [ verticalCenter, center ] (text "Events")

        Wall ->
            el NoStyle [ verticalCenter, center ] (text "Wall")

        Search ->
            viewSearchPanel model.users
    )


viewConversationsPanel conversations =
    column NoStyle
        [ height fill
        , width fill
        ]
        -- search bar
        [ row GreenBar
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
                (List.map viewConversationItem conversations)
            ]
        ]

viewConversationItem : { a | id : String } -> Element MyStyles variation Msg
viewConversationItem conversation =
    row WhiteBg
        [ height (px 80)
        , width fill
        , spacing 10
        , verticalCenter
        , padding 15
        , onClickPreventDefault (CreateConversationRequested conversation.id)
        ]
        [ image Avatar
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , caption = "Yo"
            }
        , text "Some shit here"
        ]


viewSearchPanel users =
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
                (List.map viewSearchResultItem users)
            ]
        ]


viewSearchResultItem user =
    row WhiteBg
        [ height (px 80)
        , width fill
        , spacing 10
        , verticalCenter
        , padding 15
        , onClickPreventDefault (CreateConversationRequested user.id)
        ]
        [ image Avatar
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , caption = "Yo"
            }
        , text user.username
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


viewSidenav model =
    let
        rightValue =
            if model.menu == True then
                "0"
            else
                "100%"
    in
        screen
            (column Modal
                [ inlineStyle
                    [ ( "left", rightValue ) ]
                , width fill
                , height fill
                ]
                [ row YellowBar
                    [ width fill
                    , height (px 60)
                    , padding 10
                    , alignLeft
                    , verticalCenter
                    ]
                    [ el NoStyle
                        [ class "btn-floating waves-effect btn-flat red"
                        , width (px 40)
                        , onClickPreventDefault CloseSidenavRequested
                        ]
                        (materialIcon "chevron_right" "white")
                    , row NoStyle [ center, width fill ] [ text "SideNav" ]
                    ]
                , column WhiteBg
                    [ verticalCenter, spacing 20, padding 30, height fill ]
                    [ row NoStyle
                        [ onClickPreventDefault LogOutRequested ]
                        [ materialIcon "settings" "green"
                        , text " Logout"
                        ]
                    ]
                ]
            )
