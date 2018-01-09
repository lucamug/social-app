module Main exposing (Model, Msg, init, subscriptions, update, view)

import AutoExpand
import Color exposing (blue, darkGrey, lightBlue, red, white, yellow)
import Element exposing (Element, column, el, empty, full, html, image, row, text, viewport)
import Element.Attributes exposing (..)
import Element.Events exposing (onWithOptions)
import Html exposing (textarea)
import Html.Attributes
import Json.Decode
import List.Extra exposing (elemIndex)
import Navigation exposing (Location)
import Style exposing (StyleSheet, style)
import Style.Border exposing (rounded)
import Style.Color as Color
import Style.Transition exposing (Transition, all, transitions)
import Time exposing (Time)
import Window


----------------- MODEL -------------------------------------------------


type alias Model =
    { viewportDims : { height : Int, width : Int }
    , user : Maybe User
    , autoExpandState : AutoExpand.State
    , textInput : String
    , page : Page
    }


init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    ( { viewportDims = flags
      , user = Nothing
      , autoExpandState = AutoExpand.initState config
      , textInput = ""
      , page = Conversations
      }
    , Cmd.none
    )


type alias UserId =
    String


type alias Conversation =
    { id : String
    , ownerId : UserId
    , members : List String
    , lastMessage : Message
    }


type alias User =
    { id : UserId
    , defaultPhoto : Maybe String
    , username : String
    }


type alias Message =
    { userId : String
    , content : String
    , timestamp : Time
    }



---------------------- STYLE -----------------------------------------------


type MyStyles
    = NavBar
    | Pusher
    | NoStyle
    | Avatar
    | YellowBar
    | Header
    | Sidebar
    | Main
    | Underline


stylesheet : StyleSheet MyStyles variation
stylesheet =
    Style.styleSheet
        [ style NavBar
            [ Color.background lightBlue
            ]
        , style YellowBar [ Color.background yellow ]
        , style Header [ Color.background blue ]
        , style Pusher [ transitions [ Transition 0 130 "ease-in" [ "width" ] ] ]
        , style Main [ Color.background darkGrey ]
        , style Underline []
        , style NoStyle []
        , style Avatar [ rounded 1000 ]
        , style Sidebar [ Color.background red ]
        ]



------------------------------------ UPDATE -----------------------------------------------------


type Msg
    = Resize Window.Size
    | PageNavigation Page
    | OpenConversation String
    | AutoExpandInput { textValue : String, state : AutoExpand.State }
    | LocationChanged Location


type Page
    = Conversations
    | Events
    | Wall
    | People


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize viewportDims ->
            ( { model
                | viewportDims = viewportDims
              }
            , Cmd.none
            )

        PageNavigation page ->
            ( { model | page = page }, Cmd.none )

        AutoExpandInput { state, textValue } ->
            ( { model | autoExpandState = state, textInput = textValue }, Cmd.none )

        OpenConversation id ->
            ( model, Cmd.none )

        LocationChanged location ->
            ( model, Cmd.none )


onClickPreventDefault : msg -> Element.Attribute variation msg
onClickPreventDefault msg =
    onWithOptions "click"
        { preventDefault = True, stopPropagation = True }
        (Json.Decode.succeed msg)



------------VIEW-----------------------------------------------


view : Model -> Html.Html Msg
view model =
    let
        tabList =
            [ ( "question_answer", Conversations )
            , ( "dns", Wall )
            , ( "search", People )
            , ( "date_range", Events )
            ]
    in
    viewport stylesheet <|
        column Main
            [ height fill, minHeight (percent 100), clip ]
            [ viewTab tabList model.page
            , viewMain model.page

            -- , viewTextInput model
            ]


viewMain page =
    case page of
        Conversations ->
            viewConversationList

        Events ->
            text "Events"

        Wall ->
            text "Wall"

        People ->
            text "People"


viewTextInput : { a | autoExpandState : AutoExpand.State, textInput : String } -> Element style variation Msg
viewTextInput model =
    html
        (AutoExpand.view
            config
            model.autoExpandState
            model.textInput
        )


config : AutoExpand.Config Msg
config =
    AutoExpand.config
        { onInput = AutoExpandInput
        , padding = 10
        , lineHeight = 20
        , minRows = 1
        , maxRows = 4
        }


viewConversationList : Element MyStyles variation Msg
viewConversationList =
    let
        conversations =
            [ Conversation "bb84r6" "xrere" [ "dude" ] (Message "serrerkj" "WassupDude" 4438834) ]
    in
    column NoStyle [ height fill, scrollbars ] (List.map viewConversationRow conversations)


viewTab : List ( String, Page ) -> Page -> Element MyStyles variation Msg
viewTab listMatAndPage selectedPage =
    let
        listPage =
            List.map Tuple.second listMatAndPage

        indexPage =
            elemIndex selectedPage listPage
    in
    Element.map PageNavigation
        (column NoStyle
            []
            [ row NavBar
                [ width fill, height (px 50) ]
                (List.map viewTabButton listMatAndPage)
            , viewTabUnderline (Maybe.withDefault 0 indexPage) (List.length listMatAndPage)
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


viewTabButton : ( String, Page ) -> Element MyStyles variation Page
viewTabButton ( iconName, page ) =
    row NoStyle
        [ width (fillPortion 1)
        , onClickPreventDefault page
        , center
        , verticalCenter
        ]
        [ materialIcon iconName ]


viewConversationRow : Conversation -> Element MyStyles variation Msg
viewConversationRow conversation =
    row NoStyle
        [ height (px 80), width fill, padding 5, spacing 5, onClickPreventDefault (OpenConversation conversation.id) ]
        [ image Avatar [ height (px 40), width (px 40), verticalCenter ] { src = "images/default-profile-pic.png", caption = "yo" }
        , el NoStyle [ center, verticalCenter ] (Element.text conversation.id)
        ]


materialIcon : String -> Element style variation msg
materialIcon name =
    html (Html.i [ Html.Attributes.class "material-icons" ] [ Html.text name ])



------------- subscriptions --------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes Resize


main : Program { height : Int, width : Int } Model Msg
main =
    Navigation.programWithFlags
        LocationChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
