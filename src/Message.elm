module Message exposing (..)

import Time exposing (Time)


type alias Message =
    { userId : String
    , content : String
    , timestamp : Time
    }
