port module Ports exposing (..)

port login : String -> String -> Cmd msg

port returnUser : ()