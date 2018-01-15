module Misc exposing (..)

import Element exposing (..)
import Element.Events exposing (onWithOptions)
import Html
import Html.Attributes as Attr
import Json.Decode


onClickPreventDefault msg =
    onWithOptions "click"
        { preventDefault = True, stopPropagation = True }
        (Json.Decode.succeed msg)


materialIcon : String -> String -> Element style variation msg
materialIcon name color =
    html (Html.i [ Attr.class "material-icons"
        , Attr.style [ ( "color", color ) ] ] [ Html.text name ])
