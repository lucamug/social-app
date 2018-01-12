module Route exposing (..)

import Maybe
import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, map, oneOf, parsePath, s, string)


type Route
    = Conversations
    | Events
    | Wall
    | People


route : Parser (Route -> c) c
route =
    oneOf
        [ map Conversations (s "conversations")
        , map Events (s "events")
        , map Wall (s "wall")
        , map People (s "people")
        ]


routeToString route =
    case route of
        Conversations ->
            "conversations"

        Events ->
            "events"

        Wall ->
            "wall"

        People ->
            "people"


getRoute : Location -> Route
getRoute location =
    Maybe.withDefault Conversations (parsePath route location)
