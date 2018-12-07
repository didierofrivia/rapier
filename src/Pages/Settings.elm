module Pages.Settings exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    {}


view : Model -> Html msg
view model =
    div []
        [ p [] [ text "Das Settings page" ] ]
