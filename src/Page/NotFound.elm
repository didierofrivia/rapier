module Page.NotFound exposing (Model, Msg(..), view)

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
        [ p [ onClick Noop ] [ text "Not Found" ] ]
