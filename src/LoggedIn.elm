module LoggedIn exposing (..)

import Element exposing (..)
import Dict exposing (Dict)
import List.Extra exposing (elemIndex)
import Misc exposing (materialIcon, onClickPreventDefault)
import Json.Decode as De exposing (decodeValue, string)
import Html.Attributes exposing (style, class, contenteditable)
import Element.Background as Bg
import Color exposing (rgb)
import Ports
import MyInfo exposing (MyInfo)
import User exposing (User)
import Message exposing (Message)
import Msgs exposing (LoggedInSubMsg(..), TabBarTab(..))
import ConversationMeta exposing (ConversationMeta)
import ConversationView exposing (viewConversationPanel)


type alias Model =
    { users : Dict String User
    , conversationMetas : Dict String ConversationMeta
    , conversationMessages : Dict String (List Message)
    , conversationExtras : Dict String { rows : Int, textInput : String }
    , me : MyInfo
    , showMenu : Bool
    , activeConversation : Maybe String
    , selectedTab : TabBarTab
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
    }


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
            in
                { model | conversationMessages = Dict.insert convId messages model.conversationMessages } ! []

        MessagesCancelRequested ->
            { model | activeConversation = Nothing } ! [ Ports.stopListeningToMessages () ]

        AutoExpandInput { rows, textValue } ->
            { model
                | conversationExtras =
                    Dict.insert (Maybe.withDefault "" model.activeConversation)
                        { rows = rows
                        , textInput = textValue
                        }
                        model.conversationExtras
            }
                ! []


viewLoggedIn model =
    column
        [ clip
        , inFront (viewSidenav model)
        , inFront (viewConversationPanel model)
        ]
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
                viewConversationListPanel model.me.myUserId model.conversationMetas

            Events ->
                column [] [ text "Events" ]

            Wall ->
                column [] [ text "Wall" ]

            Search ->
                viewSearchPanel model.users
        )


viewConversationListPanel myId convMetas =
    column
        []
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
        , htmlAttribute <| onClickPreventDefault (MessagesRequested convId)
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


viewSearchPanel userDict =
    let
        _ =
            Debug.log "utl" (Dict.toList userDict)
    in
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
    let
        _ =
            Debug.log "id" id

        _ =
            Debug.log "user" user
    in
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
