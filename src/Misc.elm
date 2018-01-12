module Misc exposing (..)

import Element
import Html
import Html.Events exposing (onWithOptions)
import Json.Decode

onClickPreventDefault : a -> Html.Attribute a
onClickPreventDefault msg =
    onWithOptions "click"
        { preventDefault = True, stopPropagation = True }
        (Json.Decode.succeed msg)


