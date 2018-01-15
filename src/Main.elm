module Main exposing (Model, init, subscriptions, update, view)

import Element exposing (Element, button, column, el, empty, html, row, text, viewport)
import Element.Attributes exposing (..)
import Html exposing (textarea)
import List.Extra exposing (elemIndex)
import LoggedOut exposing (viewLoggedOut)
import Ports exposing (logout, login, newUser, loggedIn, loggedOut)
import Misc exposing (onClickPreventDefault, materialIcon)
import Msgs exposing (Msg(..))
import Navigation exposing (Location, modifyUrl)
import Route exposing (..)
import Styles exposing (MyStyles(..), stylesheet)
import Window


----------------- MODEL -------------------------------------------------


type alias Model =
    { viewportDims : { height : Int, width : Int }
    , auth : Auth
    , route : Route
    , email : String
    , password : String
    }


type Auth
    = LoggedIn String
    | LoggedOut String
    | AwaitingAuth


init : { width : Int, height : Int } -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        _ =
            Debug.log "initLoc: " location
    in
    ( { viewportDims = flags
      , auth = AwaitingAuth
      , email = ""
      , password =""
      , route = Route.getRoute location
      }
    , Cmd.none
    )



------------------------------------ UPDATE -----------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
        EmailEdited email ->
            ( {model | email = email}, Cmd.none )
        PasswordEdited password ->
            ( {model | password = password}, Cmd.none )

        LogOutRequested ->
            ( model, logout "" )

        LogOutSuccess val ->
            ( {model | auth = LoggedOut ""}, Cmd.none )

        LogInSuccess uid ->
            ( {model | auth = LoggedIn uid}, Cmd.none )

        LoginRequested ->
            ( model, login {email = model.email, password = model.password} )

        UserId userId->
            ({model | auth = LoggedIn userId}, Cmd.none) 

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
            LoggedOut _ ->
                viewLoggedOut

            LoggedIn userId ->
                viewLoggedIn model

            AwaitingAuth ->
                text "awaiting"

viewLoggedIn : Model -> Element MyStyles variation Msg
viewLoggedIn model =
    column Main
        [ height fill, minHeight (percent 100), clip ]
        [ row NavBar [] [viewTab model.route, row NoStyle [center, verticalCenter, width fill, onClickPreventDefault LogOutRequested] [materialIcon "settings" "black"] ]
        , viewMain model
        ]

viewMain : Model -> Element MyStyles variation Msg
viewMain model =
    case model.route of
        Conversations ->
            text "Conversations"

        Events ->
            text "Events"

        Wall ->
            text "Wall"

        People ->
            text "People"


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
    Element.map ToRoute
        (column NoStyle
            [width (fillPortion 4)]
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
        [ materialIcon iconName "black"]





------------- subscriptions --------------------------


subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch 
    [ Window.resizes Resize
    , loggedIn LogInSuccess
    , loggedOut LogOutSuccess
    ]


main : Program { height : Int, width : Int } Model Msg
main =
    Navigation.programWithFlags
        LocationChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
