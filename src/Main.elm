module Main exposing (view)

import Data exposing (Model, Auth(..), init)
import LoggedOut exposing (viewLoggedOut)
import LoggedIn exposing (viewLoggedIn)
import Styles exposing (MyStyles(NoStyle), stylesheet)
import Msgs exposing (Msg(..))
import Update exposing(update)
import Element exposing (..)
import Element.Attributes exposing(..)
import Navigation
import Ports exposing (loggedIn, loggedOut)
import Html
import Window


------------VIEW-----------------------------------------------

view : Model -> Html.Html Msg
view model =
    viewport stylesheet <|
        let
            mainView =
                case model.auth of
                    LoggedOut status ->
                        viewLoggedOut status

                    LoggedIn userId ->
                        viewLoggedIn model

                    AwaitingAuth ->
                        text "awaiting"
        in
        column NoStyle
            [ height fill ]
            [ mainView

            ]


------------- SUBSCRIPTIONS --------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes WindowResized
        , loggedIn LoginSucceeded
        , loggedOut LogOutSucceeded
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
