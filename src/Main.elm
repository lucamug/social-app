module Main exposing (view)

import Data exposing (Model, Auth(..), init)
import LoggedOut exposing (viewLoggedOut)
import LoggedIn exposing (viewLoggedIn)
import Styles exposing (MyStyles(..), stylesheet)
import Messages exposing (Msg(..))
import Update exposing(update)
import Element exposing (..)
import Element.Attributes exposing(..)
import Navigation exposing (Location, modifyUrl)
import Ports exposing (loggedIn, loggedOut, login, logout, newUser)
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


------------- subscriptions --------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
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
