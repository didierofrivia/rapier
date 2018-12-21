module Page exposing (view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)



-- VIEW


view : Html msg -> Document msg
view page =
    { title = "Rapier"
    , body =
        template
            (div []
                [ p [] [ page ] ]
            )
    }


header : Html msg
header =
    div []
        [ p [] [ text "Header" ]
        , ul []
            [ viewLink "/" "Dashboard"
            , viewLink "/settings" "Settings"
            , viewLink "/asdasd" "asdsad"
            ]
        ]


footer : Html msg
footer =
    div []
        [ p [] [ text "Footer" ]
        ]


template : Html msg -> List (Html msg)
template content =
    [ header
    , content
    , footer
    ]


viewLink : String -> String -> Html msg
viewLink path humanName =
    li [] [ a [ href path ] [ text humanName ] ]
