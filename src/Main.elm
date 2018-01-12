module Main exposing (Model, init, subscriptions, update, view)

import Element exposing (Element, button, column, el, empty, html, row, text, viewport)
import Element.Attributes exposing (..)
import Html exposing (textarea)
import Html.Attributes
import List.Extra exposing (elemIndex)
import LoggedOut exposing (viewLoggedOut)
import Misc exposing (onClickPreventDefault)
import Msgs exposing (Msg(..))
import Navigation exposing (Location, modifyUrl)
import Process exposing (sleep)
import Route exposing (..)
import Styles exposing (MyStyles(..), stylesheet)
import Task
import Window


----------------- MODEL -------------------------------------------------


type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , route : Route
    }


type Auth
    = LoggedIn
    | LoggedOut
    | AwaitingAuth


init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        _ =
            Debug.log "initLoc: " location
    in
    ( { viewportDims = flags
      , auth = AwaitingAuth
      , route = Route.getRoute location
      }
    , Process.sleep 2000
        |> Task.attempt FinishedAuth
    )



------------------------------------ UPDATE -----------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
        UsernameAdded username ->
            ( model, Cmd.none )
        FinishedAuth (Ok ()) ->
            ( { model | auth = LoggedOut }, Cmd.none )

        FinishedAuth (Err err) ->
            ( model, Cmd.none )

        LogOutRequested ->
            ( { model | auth = LoggedOut }, Cmd.none )

        LogInRequested ->
            ( { model | auth = LoggedIn }, Cmd.none )

        Resize viewportDims ->
            ( { model
                | viewportDims = viewportDims
              }
            , Cmd.none
            )

        ToRoute route ->
            ( model, modifyUrl (Route.routeToString route) )

        LocationChanged location ->
            let
                _ =
                    Debug.log "location changed: " location
            in
            ( { model | route = getRoute location }, Cmd.none )



------------VIEW-----------------------------------------------


view : Model -> Html.Html Msg
view model =
    viewport stylesheet <|
        case model.auth of
            LoggedOut ->
                viewLoggedOut

            LoggedIn ->
                viewLoggedIn model

            AwaitingAuth ->
                text "awaiting"


viewLoggedIn model =
    let
        listTabs =
            [ ( "question_answer", Conversations )
            , ( "dns", Wall )
            , ( "search", People )
            , ( "date_range", Events )
            ]
    in
    column Main
        [ height fill, minHeight (percent 100), clip ]
        [ viewTab listTabs model.route
        , viewMain model.route
        ]


viewMain : Route -> Element MyStyles variation Msg
viewMain route =
    case route of
        Conversations ->
            text "Conversations"

        Events ->
            text "Events"

        Wall ->
            text "Wall"

        People ->
            text "People"


viewTab : List ( String, Route ) -> Route -> Element MyStyles variation Msg
viewTab listTabs selectedRoute =
    let
        indexRoute =
            List.map Tuple.second listTabs
                |> elemIndex selectedRoute
    in
    Element.map ToRoute
        (column NoStyle
            []
            [ row NavBar
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
        [ materialIcon iconName ]


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
