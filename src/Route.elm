module Route exposing (..)

import Maybe
import Navigation exposing (Location)
import Ports exposing (getAllUsers)
import UrlParser as Url exposing (Parser, map, oneOf, parsePath, s, string)


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


getRouteData : Route -> Cmd msg
getRouteData route =
    case route of
        Conversations ->
            Cmd.none
        Events ->
            Cmd.none
        Wall ->
            Cmd.none
        Search ->
            getAllUsers True