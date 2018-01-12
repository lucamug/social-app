module User exposing (..)

type alias User =
    { id : String
    , defaultPhoto : Maybe String
    , username : String
    }

