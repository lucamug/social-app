module LoggedIn exposing (..)

import Element exposing (..)
import Dict exposing (Dict)
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Json.Decode as De exposing (decodeValue, string)
import Html.Attributes exposing (style, class)
import Element.Background as Bg
import Color exposing (rgb)
import Ports
import MyInfo exposing (MyInfo)
import User exposing (User)
import Message exposing (Message)
import Msgs exposing (Msg(LoggedInMsg), LoggedInSubMsg(..), TabBarTab(..))
import Conversation exposing (..)
import ConversationView exposing (viewConversationPanel)
import ConversationListView exposing (viewConversationListPanel)
import Dom.Scroll as Scroll
import Task


type alias Model =
    { users : Dict String User
    , conversations : Dict String Conversation
    , me : MyInfo
    , showMenu : Bool
    , activeConversation : Maybe String
    , selectedTab : TabBarTab
    }


initialModel : MyInfo -> Model
initialModel myInfo =
    { users = Dict.empty
    , conversations = Dict.empty
    , me = myInfo
    , showMenu = False
    , activeConversation = Nothing
    , selectedTab = Conversations
    }


update msg model =
    case msg of
        OpenSidenavRequested ->
            { model | showMenu = True } ! []

        CloseSidenavRequested ->
            { model | showMenu = False } ! []

        SendMessageRequested convId extras image ->
            let
                newConv =
                    Dict.update
                        convId
                        (Maybe.map (\conv -> { conv | extras = { rows = 1, textInput = "" } }))
                        model.conversations
            in
                { model | conversations = newConv } ! [ Ports.sendMessage { convId = convId, text = extras.textInput, image = image } ]

        CreateConversationRequested userId ->
            model ! [ Ports.createConversation userId ]

        TabRequested tab ->
            { model | selectedTab = tab } ! []

        LogOutRequested ->
            model ! [ Ports.logout () ]

        UsersReceived usersValue ->
            { model | users = Result.withDefault Dict.empty <| decodeValue (De.dict User.decoder) usersValue } ! []

        ConvsMetaReceived convsValue ->
            let
                metaDict =
                    Result.withDefault Dict.empty <| decodeValue (De.dict Conversation.convMetaDecoder) convsValue

                metaOnly convId convMeta result =
                    Dict.insert convId { meta = convMeta, messages = [], extras = { rows = 1, textInput = "" } } result

                metaAndConv convId convMeta conv result =
                    Dict.insert convId { conv | meta = convMeta } result

                convOnly convId conv result =
                    result
            in
                { model
                    | conversations =
                        Dict.merge
                            metaOnly
                            metaAndConv
                            convOnly
                            metaDict
                            model.conversations
                            Dict.empty
                }
                    ! []

        MessagesRequested convId ->
            { model | activeConversation = Just convId } ! [ Ports.listenToMessages convId ]

        MessagesReceived messageList ->
            let
                { convId, messages } =
                    messageList
                        |> decodeValue
                            (De.map2 (\convId messages -> { convId = convId, messages = messages })
                                (De.field "convId" string)
                                (De.field "messages" (De.list Message.decoder))
                            )
                        -- TODO: should throw error instead
                        |> Result.withDefault { convId = "", messages = [] }

                updateMessages messages mayConv =
                    Maybe.map ((\messages conv -> { conv | messages = messages }) messages) mayConv
            in
                { model | conversations = Dict.update convId (updateMessages messages) model.conversations }
                    ! 
                    [Task.attempt (LoggedInMsg << MessagesScrolled) (Scroll.toBottom convId)]

        MessagesScrolled result ->
            model ! []

        MessagesCancelRequested ->
            { model | activeConversation = Nothing } ! [ Ports.stopListeningToMessages () ]

        AutoExpandInput convId { rows, textValue } ->
            let
                updateExtras extras mayConv =
                    case mayConv of
                        Just conv ->
                            Just { conv | extras = extras }

                        Nothing ->
                            Nothing
            in
                { model
                    | conversations =
                        Dict.update convId (updateExtras { rows = rows, textInput = textValue }) model.conversations
                }
                    ! []


viewSlidablePanel panel activeConvId myUserId ( convId, conv ) =
    let
        rightValue =
            case activeConvId of
                Nothing ->
                    "-100%"

                Just id ->
                    if convId == id then
                        "0"
                    else
                        "-100%"
    in
        column
            [ htmlAttribute <|
                style
                    [ ( "transition", "left 130ms ease-in" )

                    -- , ("max-height", "100vh")
                    -- , ("heigh", "100vh")
                    , ( "left", rightValue )
                    ]
            ]
            [ panel ( convId, conv ) myUserId ]


viewLoggedIn model =
    column
        ([ clip
         , inFront (viewSidenav model)
         ]
            ++ (List.map
                    (inFront
                        << (viewSlidablePanel
                                viewConversationPanel
                                model.activeConversation
                                model.me.myUserId
                           )
                    )
                    (Dict.toList model.conversations)
               )
        )
        [ viewContent model
        , row
            []
            [ viewTab model.selectedTab
            , row
                [ htmlAttribute (onClickPreventDefault OpenSidenavRequested) ]
                [ el [ centerX ] <| materialIcon "menu" "dark" ]
            ]
        ]


viewContent : Model -> Element LoggedInSubMsg
viewContent model =
    el
        [ height fill, width fill ]
        (case model.selectedTab of
            Conversations ->
                viewConversationListPanel model.me.myUserId model.conversations

            Events ->
                column [] [ text "Events" ]

            Wall ->
                column [] [ text "Wall" ]

            Search ->
                viewSearchPanel model.users
        )


viewSearchPanel userDict =
    column
        []
        -- search bar
        [ row
            [ height (px 100)
            , centerX
            ]
            [ text "TODO: search criteria" ]

        --  results list
        , column
            [ scrollbarY ]
            (List.map viewSearchResultItem (Dict.toList userDict))
        ]


viewSearchResultItem ( id, user ) =
    row
        [ height (px 80)
        , spacing 10
        , padding 15
        , htmlAttribute <| onClickPreventDefault (CreateConversationRequested id)
        ]
        [ image
            [ height (px 45) ]
            { src = "images/default-profile-pic.png"
            , description = "Yo"
            }
        , text user.username
        ]


viewTab : TabBarTab -> Element LoggedInSubMsg
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
        column
            [ width (fillPortion 4)
            ]
            [ row
                [ height (px 50) ]
                (List.map viewTabButton listTabs)
            , viewTabUnderline (Maybe.withDefault 0 indexRoute) (List.length listTabs)
            ]


viewTabUnderline : Int -> Int -> Element msg
viewTabUnderline index numTabs =
    let
        barWidth =
            100 / toFloat numTabs
    in
        row
            [ height (px 2) ]
            [ el [ width (fillPortion index) ] empty
            , el [ height (px 2), width fill, Bg.color Color.red ] empty
            , el [ width <| fillPortion <| numTabs - index - 1 ] empty
            ]


viewTabButton : ( String, TabBarTab ) -> Element LoggedInSubMsg
viewTabButton ( iconName, tab ) =
    row
        [ htmlAttribute <| onClickPreventDefault (TabRequested tab) ]
        [ el [ centerX ] <| materialIcon iconName "black" ]


viewSidenav model =
    let
        rightValue =
            if model.showMenu == True then
                "0"
            else
                "100%"
    in
        column
            [ htmlAttribute
                (style
                    [ ( "transition", "left 130ms ease-in" )
                    , ( "left", rightValue )
                    ]
                )
            , Bg.color <| rgb 255 255 255
            ]
            [ row
                [ height (px 60)
                , padding 10
                , alignLeft
                ]
                [ el
                    [ htmlAttribute <| class "btn-floating waves-effect btn-flat red"
                    , width (px 40)
                    , htmlAttribute <| onClickPreventDefault CloseSidenavRequested
                    ]
                    (materialIcon "chevron_right" "black")
                , row [ centerX ] [ text "SideNav" ]
                ]
            , column
                [ centerY, spacing 20, padding 30 ]
                [ row
                    [ htmlAttribute <| onClickPreventDefault LogOutRequested ]
                    [ materialIcon "settings" "green"
                    , text " Logout"
                    ]
                ]
            ]
