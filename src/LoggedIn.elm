module LoggedIn exposing (..)

import AutoExpand
import Element exposing (Element, toHtml, image, button, column, el, empty, h1, html, row, screen, text, viewport)
import Element.Attributes exposing (..)
import List
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Styles exposing (MyStyles(..), stylesheet)
import Json.Decode as De exposing (decodeValue)
import Ports
import User exposing (User)
import Message exposing(Message)
import Conversation exposing (Conversation)


config : AutoExpand.Config Msg
config =
    AutoExpand.config
        { onInput = AutoExpandInput
        , padding = 10
        , lineHeight = 20
        , minRows = 1
        , maxRows = 10
        }
        |> AutoExpand.withStyles [("height", "auto"), ("border", "none"), ("outline", "none"), ("box-shadow", "none")]
        |> AutoExpand.withPlaceholder "Type a message"

type alias Model =
    { users : List User
    , conversations : Maybe (List Conversation)
    , messages: Maybe (List Message)
    , myUserInfo : User
    , showMenu : Bool
    , activeConversation : Maybe Conversation
    , selectedTab : TabBarTab
    , autoExpand : AutoExpand.State
    , textInput: String
    }


initialModel : User -> Model
initialModel user =
    { users = []
    , conversations = Nothing
    , messages = Nothing
    , myUserInfo = user
    , showMenu = False
    , activeConversation = Nothing
    , selectedTab = Conversations
    , autoExpand = AutoExpand.initState config
    , textInput = ""
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
    | ConvReceived De.Value
    | AutoExpandInput { textValue : String, state : AutoExpand.State }


update msg model =
    case msg of
        OpenSidenavRequested ->
            { model | showMenu = True } ! []

        CloseSidenavRequested ->
            { model | showMenu = False } ! []

        CreateConversationRequested userId ->
            model ! [ Ports.createConversation userId ]

        ViewConversationRequested convId ->
            model ! [ Ports.listenToConversation convId ]

        TabRequested tab ->
            { model | selectedTab = tab } ! []

        LogOutRequested ->
            model ! [ Ports.logout () ]

        UsersReceived usersValue ->
            { model | users = Result.withDefault [] <| decodeValue (De.list User.decoder) usersValue } ! []

        ConvsMetaReceived convsValue ->
            { model | conversations = Result.toMaybe <| decodeValue (De.list Conversation.decoder) convsValue } ! []

        ConvReceived messageList ->
            { model | messages = Result.toMaybe <| decodeValue (De.list Message.decoder) messageList } ! []
        
        CancelConversationRequested ->
            model ! [Ports.cancelConversation ()]

        AutoExpandInput {state, textValue} ->
            { model | autoExpand = state, textInput = textValue } ! []


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
                case model.conversations of 
                    Nothing ->
                        el NoStyle [] (text "loading convs..")
                    Just convs ->
                        viewConversationsPanel model.myUserInfo.id convs

            Events ->
                el NoStyle [ verticalCenter, center ] (text "Events")

            Wall ->
                el NoStyle [ verticalCenter, center ] (text "Wall")

            Search ->
                viewSearchPanel model.users
        )


viewConversationsPanel myId convs =
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
                (List.map (viewConversationItem myId) convs )
            ]
        ]


viewConversationItem myId conversation =
    row WhiteBg
        [ height (px 80)
        , width fill
        , spacing 10
        , verticalCenter
        , padding 15
        , onClickPreventDefault (ViewConversationRequested conversation.id)
        ]
        [ image Avatar
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , caption = "Yo"
            }
        , conversation.members
            |> List.filter (\member -> member.id /= myId)
            |> List.map .username
            |> String.join ", "
            |> text
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
            case model.messages of
                Nothing ->
                    "100%"
                Just messages ->
                    "0"
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
                    []
                , viewTextInput model

                ]


viewTextInput { autoExpand, textInput } =
    el WhiteBg [] <| html <| AutoExpand.view config autoExpand textInput