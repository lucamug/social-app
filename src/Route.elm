module Route exposing (..)

import Maybe
import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, map, oneOf, parsePath, s, string)
import Ports

type Route
    = Conversations
    | Events
    | Wall
    | Search

route : Parser (Route -> c) c
route =
    oneOf
        [ map Conversations (s "conversations")
        , map Events (s "events")
        , map Wall (s "wall")
        , map Search (s "search")
        ]


routeToString : Route -> String
routeToString route =
    case route of
        Conversations ->
            "conversations"

        Events ->
            "events"

        Wall ->
            "wall"

        Search ->
            "search"


getRoute : Location -> Route
getRoute location =
    Maybe.withDefault Conversations (parsePath route location)

fetchRouteData : Route -> Cmd msg
fetchRouteData route =
    case route of
        Conversations ->
            Ports.listenToConvMetas ()
        
        -- Conversation conv ->
        --     Ports.listenToConv conv

        Events ->
            Cmd.none

        Wall ->
            Cmd.none

        Search ->
            Ports.getAllOtherUsers ()
