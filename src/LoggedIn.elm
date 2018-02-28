module LoggedIn exposing (..)

import AutoExpand
import Element exposing (Element, toHtml, image, button, column, el, empty, h1, html, row, screen, text, viewport)
import Element.Attributes exposing (..)
import Dict exposing (Dict)
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Styles exposing (MyStyles(..), stylesheet)
import Json.Decode as De exposing (decodeValue, string)
import Ports
import MyInfo exposing (MyInfo)
import User exposing (User)
import Message exposing (Message)
import ConversationMeta exposing (ConversationMeta)


config conversationId =
    AutoExpand.config
        { onInput = AutoExpandInput conversationId
        , padding = 10
        , lineHeight = 20
        , minRows = 1
        , maxRows = 10
        }
        |> AutoExpand.withStyles [ ( "height", "auto" ), ( "border", "none" ), ( "outline", "none" ), ( "box-shadow", "none" ) ]
        |> AutoExpand.withPlaceholder "Type a message"


type alias Model =
    { users : Dict String User
    , conversationMetas : Dict String ConversationMeta
    , conversationMessages : Dict String (List Message)
    , conversationExtras : Dict String { autoExpand : AutoExpand.State, textInput : String }
    , me : MyInfo
    , showMenu : Bool
    , activeConversation : Maybe String
    , selectedTab : TabBarTab

    -- , autoExpand : AutoExpand.State
    -- , textInput : String
    }


initialModel : MyInfo -> Model
initialModel myInfo =
    { users = Dict.empty
    , conversationMetas = Dict.empty
    , conversationMessages = Dict.empty
    , conversationExtras = Dict.empty
    , me = myInfo
    , showMenu = False
    , activeConversation = Nothing
    , selectedTab = Conversations

    -- , autoExpand = AutoExpand.initState config
    -- , textInput = ""
    }


type TabBarTab
    = Conversations
    | Events
    | Wall
    | Search


type Msg
    = OpenSidenavRequested
    | CloseSidenavRequested
    | ViewConversationRequested String
    | CancelConversationRequested
    | CreateConversationRequested String
    | TabRequested TabBarTab
    | LogOutRequested
    | UsersReceived De.Value
    | ConvsMetaReceived De.Value
    | MessagesReceived De.Value
    | AutoExpandInput String { textValue : String, state : AutoExpand.State }


update msg model =
    case msg of
        OpenSidenavRequested ->
            { model | showMenu = True } ! []

        CloseSidenavRequested ->
            { model | showMenu = False } ! []

        CreateConversationRequested userId ->
            model ! [ Ports.createConversation userId ]

        TabRequested tab ->
            { model | selectedTab = tab } ! []

        LogOutRequested ->
            model ! [ Ports.logout () ]

        UsersReceived usersValue ->
            { model | users = Result.withDefault Dict.empty <| decodeValue (De.dict User.decoder) usersValue } ! []

        ConvsMetaReceived convsValue ->
            { model | conversationMetas = Result.withDefault Dict.empty <| decodeValue (De.dict ConversationMeta.decoder) convsValue } ! []

        ViewConversationRequested convId ->
            let
                conversationExtras =
                    Dict.update convId
                        (\v ->
                            case v of
                                Nothing ->
                                    Just { autoExpand = AutoExpand.initState (config convId), textInput = "" }

                                Just val ->
                                    Just val
                        )
                        model.conversationExtras
            in
                { model | activeConversation = Just convId, conversationExtras = conversationExtras } ! [ Ports.listenToMessages convId ]

        MessagesReceived messageList ->
            let
                { convId, messages } =
                    messageList
                        |> decodeValue
                            (De.map2 (\convId messages -> { convId = convId, messages = messages })
                                (De.field "convId" string)
                                (De.field "messages" (De.list Message.decoder))
                            )
                        |> Result.withDefault { convId = "", messages = [] }
            in
                { model | conversationMessages = Dict.insert convId messages model.conversationMessages } ! []

        CancelConversationRequested ->
            { model | activeConversation = Nothing } ! [ Ports.cancelConversation () ]

        AutoExpandInput convId { state, textValue } ->
            -- { model | autoExpand = state, textInput = textValue } ! []
            { model | conversationExtras = Dict.insert convId { autoExpand = state, textInput = textValue } model.conversationExtras } ! []


viewLoggedIn : Model -> Element MyStyles variation Msg
viewLoggedIn model =
    column Main
        [ height fill, minHeight (percent 100), clip ]
        [ viewContent model
        , row NavBar
            []
            [ viewTab model.selectedTab
            , row NoStyle
                [ center
                , verticalCenter
                , width fill
                , onClickPreventDefault OpenSidenavRequested
                ]
                [ materialIcon "menu" "dark" ]
            ]
        , viewSidenav model
        , viewConversationPanel model
        ]


viewContent : Model -> Element MyStyles variation Msg
viewContent model =
    el NoStyle
        [ height fill, width fill ]
        (case model.selectedTab of
            Conversations ->
                viewConversationsPanel model.me.myUserId model.conversationMetas

            Events ->
                el NoStyle [ verticalCenter, center ] (text "Events")

            Wall ->
                el NoStyle [ verticalCenter, center ] (text "Wall")

            Search ->
                viewSearchPanel model.users
        )


viewConversationsPanel myId convMetas =
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
            [ text "TODO: conversation criteria" ]

        --  results list
        , row NoStyle
            [ height fill, width fill ]
            [ column NoStyle
                [ yScrollbar, width fill ]
                (List.map (viewConversationItem myId) <| Dict.toList convMetas)
            ]
        ]


viewConversationItem myId ( convId, convMeta ) =
    row WhiteBg
        [ height (px 80)
        , width fill
        , spacing 10
        , verticalCenter
        , padding 15
        , onClickPreventDefault (ViewConversationRequested convId)
        ]
        [ image Avatar
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , caption = "Yo"
            }
        , convMeta.members
            |> Dict.filter (\id member -> id /= myId)
            |> Dict.toList
            |> List.map (\( id, member ) -> member.username)
            |> String.join ", "
            |> text
        ]


viewSearchPanel userDict =
    let
        _ =
            Debug.log "utl" (Dict.toList userDict)
    in
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
                    (List.map viewSearchResultItem (Dict.toList userDict))
                ]
            ]


viewSearchResultItem ( id, user ) =
    let
        _ =
            Debug.log "id" id

        _ =
            Debug.log "user" user
    in
        row WhiteBg
            [ height (px 80)
            , width fill
            , spacing 10
            , verticalCenter
            , padding 15
            , onClickPreventDefault (CreateConversationRequested id)
            ]
            [ image Avatar
                [ height (px 45) ]
                { src = "images/default-profile-pic.png"
                , caption = "Yo"
                }
            , text user.username
            ]


viewTab : TabBarTab -> Element MyStyles variation Msg
viewTab selectedTab =
    let
        listTabs =
            [ ( "question_answer", Conversations )
            , ( "dns", Wall )
            , ( "search", Search )
            , ( "date_range", Events )
            ]

        indexRoute =
            List.map Tuple.second listTabs
                |> elemIndex selectedTab
    in
        Element.map TabRequested
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


viewTabButton : ( String, TabBarTab ) -> Element MyStyles variation TabBarTab
viewTabButton ( iconName, tab ) =
    row NoStyle
        [ width (fillPortion 1)
        , onClickPreventDefault tab
        , center
        , verticalCenter
        ]
        [ materialIcon iconName "black" ]


viewSidenav model =
    let
        rightValue =
            if model.showMenu == True then
                "0"
            else
                "100%"
    in
        screen <|
            column Modal
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
        screen <|
            column Modal
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
                    [ row NoStyle [ center, width fill ] [ text "Conversation" ]
                    , el NoStyle
                        [ class "btn-floating waves-effect btn-flat red"
                        , width (px 40)
                        , onClickPreventDefault CancelConversationRequested
                        ]
                        (materialIcon "chevron_right" "white")
                    ]
                , column FaintGrayBg
                    [ spacing 20, padding 30, height fill ]
                    (List.map (viewMessageLine model.me.myUserId) messages)
                , viewTextInput model
                ]


viewMessageLine myUserId message =
    row NoStyle [] [ text message.content ]


viewTextInput { conversationExtras, activeConversation } =
    case activeConversation of
        Nothing ->
            text "error"

        Just convId ->
            case Dict.get convId conversationExtras of
                Nothing ->
                    text "error"

                Just { autoExpand, textInput } ->
                    el WhiteBg [] <| html <| AutoExpand.view (config convId) autoExpand textInput
