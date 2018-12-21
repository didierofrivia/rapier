module Page.Dashboard exposing (Model, Msg(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (..)


type alias Model =
    { session : Session }


type Msg
    = Noop


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Noop ] [ text "Le Dashboard page" ] ]
